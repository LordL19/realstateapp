import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../config/api_config.dart';

class ProfileService {
  static final _client = http.Client();
  final _baseUrl = ApiConfig.getBaseUrl(Microservice.users);
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  String get baseUrl {
    if (kIsWeb) {
      // Para Flutter Web (Edge, Chrome, etc.)
      return "http://localhost:5001";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Para emulador Android
      return "http://10.0.2.2:5001";
    } else {
      // Para iOS o dispositivos físicos
      return "http://localhost:5001";
    }
  }

  Future<UserProfile?> getProfile() async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) return null;

      final response = await _client
          .get(
            Uri.parse('$_baseUrl/user/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'jwt');
      }
      return null;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al cargar perfil: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}