import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session tokens returned by login, OTP verify and refresh.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    role: json['role'] as String,
  );

  final String accessToken;
  final String refreshToken;
  final String role;
}

abstract interface class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'eds.access_token';
  static const _refreshKey = 'eds.refresh_token';
  static const _roleKey = 'eds.role';

  // Cached so the interceptor doesn't hit the keychain on every request.
  AuthTokens? _cache;
  bool _loaded = false;

  @override
  Future<AuthTokens?> read() async {
    if (_loaded) return _cache;
    final values = await Future.wait([
      _storage.read(key: _accessKey),
      _storage.read(key: _refreshKey),
      _storage.read(key: _roleKey),
    ]);
    _loaded = true;
    if (values.any((v) => v == null)) return _cache = null;
    return _cache = AuthTokens(
      accessToken: values[0]!,
      refreshToken: values[1]!,
      role: values[2]!,
    );
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    _cache = tokens;
    _loaded = true;
    await Future.wait([
      _storage.write(key: _accessKey, value: tokens.accessToken),
      _storage.write(key: _refreshKey, value: tokens.refreshToken),
      _storage.write(key: _roleKey, value: tokens.role),
    ]);
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _roleKey),
    ]);
  }
}
