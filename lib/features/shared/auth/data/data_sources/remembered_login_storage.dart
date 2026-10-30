import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What "Remember me" on sign in keeps on this device: the phone number
/// (national digits, e.g. `3001234567`) and the email, each saved by its
/// own login. Never holds a password.
abstract interface class RememberedLoginStorage {
  Future<String?> readPhone();
  Future<void> writePhone(String digits);
  Future<void> clearPhone();

  Future<String?> readEmail();
  Future<void> writeEmail(String email);
  Future<void> clearEmail();
}

class SecureRememberedLoginStorage implements RememberedLoginStorage {
  SecureRememberedLoginStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _phoneKey = 'eds.remembered_phone';
  static const _emailKey = 'eds.remembered_email';

  @override
  Future<String?> readPhone() => _storage.read(key: _phoneKey);

  @override
  Future<void> writePhone(String digits) =>
      _storage.write(key: _phoneKey, value: digits);

  @override
  Future<void> clearPhone() => _storage.delete(key: _phoneKey);

  @override
  Future<String?> readEmail() => _storage.read(key: _emailKey);

  @override
  Future<void> writeEmail(String email) =>
      _storage.write(key: _emailKey, value: email);

  @override
  Future<void> clearEmail() => _storage.delete(key: _emailKey);
}
