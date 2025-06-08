import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';

class ProfileService {
  static final _client = http.Client();
  final baseUrl = "http://10.0.2.2:5000";
  final storage = const FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);

  Future<UserProfile?> getProfile() async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) return null;

      final response = await _client
          .get(
            Uri.parse('$baseUrl/auth/profile'),
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