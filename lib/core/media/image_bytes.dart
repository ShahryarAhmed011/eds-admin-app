import 'dart:typed_data';
import 'dart:ui' as ui;

/// Whether [bytes] decode as a picture at all. Bytes the server sends can
/// be corrupt (a bad placeholder, a truncated upload); a header check isn't
/// enough, so one thumbnail-sized frame is decoded — cheap enough to run on
/// every image a record arrives with.
Future<bool> decodesAsImage(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 16);
    try {
      (await codec.getNextFrame()).image.dispose();
    } finally {
      codec.dispose();
    }
    return true;
  } catch (_) {
    return false;
  }
}
