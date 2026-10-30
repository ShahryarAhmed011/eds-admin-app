import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../session/onboarding.dart';
import '../session/session_cache.dart';
import 'local_database.dart';

/// [SessionCache] on the `users` and `profiles` tables. Columns are
/// snake_case; values go in and come out with the API's camelCase field
/// names (`phone_number` column ↔ `phoneNumber`). The store is kept whole
/// as JSON in the `store` table.
class SqliteSessionCache implements SessionCache {
  SqliteSessionCache(this._database);

  final LocalDatabase _database;

  static ({String table, List<String> columns, List<String> flags})? _tableFor(
    String key,
  ) => switch (key) {
    SessionCacheKeys.user => (
      table: UsersTable.name,
      columns: UsersTable.columns,
      flags: UsersTable.flags,
    ),
    SessionCacheKeys.profile => (
      table: ProfilesTable.name,
      columns: ProfilesTable.columns,
      flags: ProfilesTable.flags,
    ),
    SessionCacheKeys.profilePhoto => (
      table: ProfilePhotoTable.name,
      columns: ProfilePhotoTable.columns,
      flags: const <String>[],
    ),
    _ => null,
  };

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    if (key == SessionCacheKeys.store) return _readDocument(StoreTable.name);
    final table = _tableFor(key);
    if (table == null) return null;
    final rows = await (await _database.db).query(table.table, limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return {
      for (final column in table.columns)
        if (row[column] != null) camelCase(column): row[column],
      for (final flag in table.flags)
        if (row[flag] != null) camelCase(flag): row[flag] == 1,
    };
  }

  /// Replaces the table's row: there is one signed-in account.
  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    if (key == SessionCacheKeys.store) {
      return _writeDocument(StoreTable.name, value);
    }
    final table = _tableFor(key);
    if (table == null) return;
    final row = <String, Object?>{
      for (final column in table.columns) column: _text(value, column),
      for (final flag in table.flags) flag: _flag(value, flag),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final db = await _database.db;
    await db.transaction((txn) async {
      await txn.delete(table.table);
      await txn.insert(table.table, row);
    });
  }

  @override
  Future<void> clear() => _database.clearAccount();

  /// The one row of a JSON document table, decoded; null when empty or
  /// unreadable.
  Future<Map<String, dynamic>?> _readDocument(String table) async {
    final rows = await (await _database.db).query(table, limit: 1);
    final raw = rows.firstOrNull?['json'];
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } on FormatException {
      return null;
    }
  }

  /// Replaces the document (id 1).
  Future<void> _writeDocument(String table, Map<String, dynamic> value) async {
    await (await _database.db).insert(table, {
      'id': 1,
      'json': jsonEncode(value),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Column value from API JSON; ids and numbers kept as text except
  /// `role_id`. `city_name` also comes as the `city` object's name.
  static Object? _text(Map<String, dynamic> json, String column) {
    final value = switch (column) {
      'city_name' => json['cityName'] ?? (json['city'] as Map?)?['name'],
      _ => json[camelCase(column)],
    };
    if (value == null) return null;
    if (column == 'role_id') {
      return value is int ? value : int.tryParse('$value');
    }
    return '$value';
  }

  /// 1 / 0 / null. `isPhoneVerified` also comes as `phoneVerified`.
  static int? _flag(Map<String, dynamic> json, String flag) {
    final value = switch (flag) {
      'is_phone_verified' => json['isPhoneVerified'] ?? json['phoneVerified'],
      _ => json[camelCase(flag)],
    };
    return value is bool ? (value ? 1 : 0) : null;
  }
}

/// [OnboardingStorage] on the single-row `onboarding_status` table.
class SqliteOnboardingStorage implements OnboardingStorage {
  SqliteOnboardingStorage(this._database);

  final LocalDatabase _database;

  @override
  Future<OnboardingStatus?> read() async {
    final rows = await (await _database.db).query(
      OnboardingTable.name,
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    bool flag(String column) => row[column] == 1;
    return OnboardingStatus(
      emailVerified: flag('is_email_verified'),
      phoneVerified: flag('is_phone_verified'),
      profileCreated: flag('is_profile_created'),
      storeCreated: flag('is_store_created'),
      kycCompleted: flag('is_kyc_completed'),
      canGoLive: flag('can_go_live'),
      catalogCount: (row['catalog_count'] as int?) ?? 0,
      verifyVia: row['verify_via'] == VerifyVia.email.name
          ? VerifyVia.email
          : VerifyVia.phone,
    );
  }

  @override
  Future<void> write(OnboardingStatus status) async {
    int bit(bool value) => value ? 1 : 0;
    await (await _database.db).insert(OnboardingTable.name, {
      'id': 1,
      'is_email_verified': bit(status.emailVerified),
      'is_phone_verified': bit(status.phoneVerified),
      'is_profile_created': bit(status.profileCreated),
      'is_store_created': bit(status.storeCreated),
      'is_kyc_completed': bit(status.kycCompleted),
      'can_go_live': bit(status.canGoLive),
      'catalog_count': status.catalogCount,
      'verify_via': status.verifyVia.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> clear() async =>
      (await _database.db).delete(OnboardingTable.name);
}

/// `phone_number` → `phoneNumber`: a column's API field name.
String camelCase(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts
          .skip(1)
          .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
          .join();
}
