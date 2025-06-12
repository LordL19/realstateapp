import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageHelper {
  static final _picker = ImagePicker();

  /// Selección múltiple con límite configurable (por defecto 10).
  static Future<List<XFile>> pickImages({int maxImages = 10}) async {
    final imgs = await _picker.pickMultiImage(
      imageQuality: 100, // sin compresión en la selección
    );
    return imgs.take(maxImages).toList();
  }

  /// Ahora devuelve un XFile comprimido o original en Web
  static Future<XFile?> compressFile(
    XFile xFile, {
    int quality = 80,
  }) async {
    if (kIsWeb) return xFile;

    // ruta de salida
    final targetPath = '${xFile.path}_compressed.jpg';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      xFile.path,
      targetPath,
      quality: quality,
    );

    // Si falla, devolvemos el original
    if (compressed == null) return xFile;
    return XFile(compressed.path);
  }
}
