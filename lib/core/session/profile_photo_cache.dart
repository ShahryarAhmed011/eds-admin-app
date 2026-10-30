import 'dart:convert';
import 'dart:typed_data';

import 'session_cache.dart';

/// The signed-in user's profile picture on the device: fetched once,
/// replaced on upload, dropped on remove and on sign out.
class ProfilePhotoCache {
  const ProfilePhotoCache(this._cache);

  final SessionCache _cache;

  /// The stored picture, or null when none is stored yet.
  Future<Uint8List?> read() async {
    final value = (await _cache.read(SessionCacheKeys.profilePhoto))?['bytes'];
    if (value is! String || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } on FormatException {
      return null;
    }
  }

  /// Stores [bytes]; null forgets the picture.
  Future<void> write(Uint8List? bytes) => _cache.write(
    SessionCacheKeys.profilePhoto,
    {'bytes': bytes == null ? null : base64Encode(bytes)},
  );

  /// Cached picture, else [fetch] once (when [hasPhoto]) and keep it.
  Future<Uint8List?> get({
    required bool hasPhoto,
    required Future<Uint8List?> Function() fetch,
  }) async {
    if (!hasPhoto) return null;
    final cached = await read();
    if (cached != null) return cached;
    final bytes = await fetch();
    if (bytes != null) await write(bytes);
    return bytes;
  }
}
