import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The app's SQLite database (`eds.db`): the signed-in account's data,
/// kept so screens don't refetch it. Tokens are not here; they stay in the
/// secure keychain. Every table is emptied on sign out.
class LocalDatabase {
  LocalDatabase({this.name = 'eds.db'});

  final String name;

  static const _version = 6;

  /// Tables holding the signed-in account's data.
  static const userTables = [
    UsersTable.name,
    ProfilesTable.name,
    OnboardingTable.name,
    ProfilePhotoTable.name,
    StoreTable.name,
  ];

  Future<Database>? _db;

  /// Opens on first use. Gives up after a few seconds (e.g. a build
  /// without the SQLite plugin) so nothing waits forever; the next call
  /// tries again.
  Future<Database> get db => _db ??= _open()
      .timeout(const Duration(seconds: 5))
      .catchError((Object error) {
        _db = null;
        throw StateError('Local database unavailable: $error');
      });

  Future<Database> _open() async => openDatabase(
    p.join(await getDatabasesPath(), name),
    version: _version,
    onCreate: (db, _) async {
      final batch = db.batch()
        ..execute(UsersTable.create)
        ..execute(ProfilesTable.create)
        ..execute(OnboardingTable.create)
        ..execute(ProfilePhotoTable.create)
        ..execute(StoreTable.create);
      await batch.commit(noResult: true);
    },
    onUpgrade: (db, from, _) async {
      // v2: the address typed when a town has no areas.
      if (from < 2) {
        await db.execute(
          'ALTER TABLE ${ProfilesTable.name} ADD COLUMN address TEXT',
        );
      }
      // v3: whether a profile picture is set.
      if (from < 3) {
        await db.execute(
          'ALTER TABLE ${ProfilesTable.name} '
          'ADD COLUMN has_profile_image INTEGER',
        );
      }
      // v4: the profile picture itself.
      if (from < 4) await db.execute(ProfilePhotoTable.create);
      // v5: a retailer's store (`GET /store`), as one JSON document.
      if (from < 5) await db.execute(StoreTable.create);
      // v6: how many products the store lists (onboarding's catalog gate).
      if (from < 6) {
        await db.execute(
          'ALTER TABLE ${OnboardingTable.name} ADD COLUMN catalog_count INTEGER',
        );
      }
    },
  );

  /// Empties every account table (sign out).
  Future<void> clearAccount() async {
    final database = await db;
    await database.transaction((txn) async {
      for (final table in userTables) {
        await txn.delete(table);
      }
    });
  }
}

/// The `user` block of the login / sign up response.
abstract final class UsersTable {
  static const name = 'users';

  static const create =
      '''
    CREATE TABLE $name (
      id TEXT PRIMARY KEY,
      email TEXT,
      first_name TEXT,
      last_name TEXT,
      username TEXT,
      active INTEGER,
      updated_at TEXT NOT NULL
    )''';

  static const columns = ['id', 'email', 'first_name', 'last_name', 'username'];
  static const flags = ['active'];
}

/// `GET /profile` data.
abstract final class ProfilesTable {
  static const name = 'profiles';

  static const create =
      '''
    CREATE TABLE $name (
      id TEXT PRIMARY KEY,
      email TEXT,
      role TEXT,
      role_id INTEGER,
      phone_country_code TEXT,
      phone_number TEXT,
      first_name TEXT,
      last_name TEXT,
      username TEXT,
      date_of_birth TEXT,
      gender TEXT,
      profile_image_url TEXT,
      country_id TEXT,
      state_id TEXT,
      city_id TEXT,
      town_id TEXT,
      area_id TEXT,
      city_name TEXT,
      address TEXT,
      postal_code TEXT,
      onboarding_status TEXT,
      active INTEGER,
      profile_completed INTEGER,
      is_email_verified INTEGER,
      is_phone_verified INTEGER,
      has_profile_image INTEGER,
      updated_at TEXT NOT NULL
    )''';

  static const columns = [
    'id',
    'email',
    'role',
    'role_id',
    'phone_country_code',
    'phone_number',
    'first_name',
    'last_name',
    'username',
    'date_of_birth',
    'gender',
    'profile_image_url',
    'country_id',
    'state_id',
    'city_id',
    'town_id',
    'area_id',
    'city_name',
    'address',
    'postal_code',
    'onboarding_status',
  ];
  static const flags = [
    'active',
    'profile_completed',
    'is_email_verified',
    'is_phone_verified',
    'has_profile_image',
  ];
}

/// The profile picture (base64), so it isn't downloaded on every screen.
abstract final class ProfilePhotoTable {
  static const name = 'profile_photo';

  static const create =
      '''
    CREATE TABLE $name (
      bytes TEXT,
      updated_at TEXT NOT NULL
    )''';

  static const columns = ['bytes'];
}

/// `GET /store` data as one JSON document: one row (id 1). The body has
/// nested hours and a checklist, so it is kept whole rather than in columns.
abstract final class StoreTable {
  static const name = 'store';

  static const create =
      '''
    CREATE TABLE $name (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      json TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''';
}

/// The onboarding `status` block: one row (id 1).
abstract final class OnboardingTable {
  static const name = 'onboarding_status';

  static const create =
      '''
    CREATE TABLE $name (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      is_email_verified INTEGER NOT NULL,
      is_phone_verified INTEGER NOT NULL,
      is_profile_created INTEGER NOT NULL,
      is_store_created INTEGER NOT NULL,
      is_kyc_completed INTEGER NOT NULL,
      can_go_live INTEGER NOT NULL,
      catalog_count INTEGER,
      verify_via TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''';
}
