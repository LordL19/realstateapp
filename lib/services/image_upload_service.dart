import 'dart:convert';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final _picker = ImagePicker();
  static const String _cloudName = 'dvthxzbg3';
  static const String _uploadPreset = 'ml_default';

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Error al seleccionar la imagen: $e');
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage();
    } catch (e) {
      print('Error al seleccionar múltiples imágenes: $e');
      return [];
    }
  }

  Future<String?> uploadImage(XFile imageFile) async {
    if (kIsWeb) {
      return _uploadImageWeb(imageFile);
    } else {
      return _uploadImageMobile(imageFile);
    }
  }

  Future<String?> _uploadImageMobile(XFile imageFile) async {
    try {
      final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error al subir la imagen (móvil): $e');
      return null;
    }
  }

  Future<String?> _uploadImageWeb(XFile imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    try {
      final bytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: imageFile.name,
          ),
        );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Error en la respuesta de Cloudinary (web): ${response.reasonPhrase}');
        print('Cuerpo del error: $errorBody');
        return null;
      }
    } catch (e) {
      print('Error al subir la imagen (web): $e');
      return null;
    }
  }
}