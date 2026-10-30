/// Signed-in data kept on the device (the login `user`, the profile, a
/// retailer's store) so screens don't refetch it. Cleared on sign out.
abstract interface class SessionCache {
  Future<Map<String, dynamic>?> read(String key);
  Future<void> write(String key, Map<String, dynamic> value);
  Future<void> clear();
}

abstract final class SessionCacheKeys {
  /// The `user` block of the login / sign up response.
  static const user = 'user';

  /// `GET /profile` data.
  static const profile = 'profile';

  /// The profile picture, base64 (`bytes`), so it's downloaded once.
  static const profilePhoto = 'profilePhoto';

  /// `GET /store` data, the whole body, so store screens don't refetch it.
  static const store = 'store';
}

/// Session-only cache (tests, or when nothing should persist).
class MemorySessionCache implements SessionCache {
  final _values = <String, Map<String, dynamic>>{};

  @override
  Future<Map<String, dynamic>?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, Map<String, dynamic> value) async =>
      _values[key] = value;

  @override
  Future<void> clear() async => _values.clear();
}
