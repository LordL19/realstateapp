import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Para detectar plataforma
import 'dart:io' show Platform;
class AuthService {
  static final _client = http.Client();
  final storage = const FlutterSecureStorage();

  // CONFIGURACIÓN AUTOMÁTICA SEGÚN PLATAFORMA
String get baseUrl {
  if (kIsWeb) {
    return "http://localhost:63063";
  } else if (Platform.isAndroid) {
    // Cambiar a IP de tu PC real si estás usando DISPOSITIVO físico
    return "http://192.168.100.43:63063"; // <-- CAMBIA ESTA IP si tu red ha cambiado
  } else {
    return "http://localhost:63063"; // para iOS simulador o Windows
  }
}


  static const _timeout = Duration(seconds: 30);

  /// MÉTODO DE DEBUG PARA VERIFICAR CONECTIVIDAD
  Future<bool> testConnection() async {
    try {
      developer.log('Probando conexión a: $baseUrl');
      developer.log('Plataforma: ${kIsWeb ? "WEB" : "MOBILE"}');

      // Probar endpoint simple primero
      final response = await _client.get(
        Uri.parse('$baseUrl'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('Respuesta del servidor: ${response.statusCode}');
      return response.statusCode == 200 ||
          response.statusCode ==
              404; // 404 también indica que el servidor responde
    } catch (e) {
      developer.log('Error de conexión: $e');
      return false;
    }
  }

  /// Login con debug
  Future<String?> login(String email, String password) async {
    try {
      developer.log('Intentando login para: $email');
      developer.log('URL: $baseUrl/auth/login');
      developer.log('Plataforma: ${kIsWeb ? "WEB (Edge/Chrome)" : "MOBILE"}');

      final requestBody = {
        "email": email.trim(),
        "password": password.trim(),
      };

      developer.log('Enviando datos: ${jsonEncode(requestBody)}');

      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Access-Control-Allow-Origin': '*', // Para CORS en web
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      developer.log('Respuesta recibida - Código: ${response.statusCode}');
      developer.log('Respuesta body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await storage.write(key: 'jwt', value: token);
          developer.log('Login exitoso, token guardado');
          return token;
        }
      }

      developer.log('Login fallido - Status: ${response.statusCode}');
      return null;
    } on TimeoutException {
      developer.log('Timeout en login');
      throw Exception(
          'Tiempo de espera agotado. ¿Está tu API corriendo en localhost:5000?');
    } on FormatException catch (e) {
      developer.log('Error de formato: $e');
      throw Exception('Respuesta del servidor inválida');
    } catch (e) {
      developer.log('Error general en login: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Error CORS: Configura CORS en tu API C#');
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Registro con debug completo
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      developer.log('Intentando registro para: $email');
      developer.log('URL: $baseUrl/auth/register');
      developer.log('Plataforma: ${kIsWeb ? "WEB (Edge/Chrome)" : "MOBILE"}');

      final requestBody = {
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "email": email.trim(),
        "password": password.trim(),
        "phoneNumber": phoneNumber.trim(),
        "dateOfBirth": dateOfBirth,
        "gender": gender,
        "country": country.trim(),
        "city": city.trim(),
      };

      developer.log('Enviando datos de registro:');
      developer.log(jsonEncode(requestBody));

      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Access-Control-Allow-Origin': '*', // Para CORS en web
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      developer.log('Respuesta registro - Código: ${response.statusCode}');
      developer.log('Respuesta body: ${response.body}');

      final success = response.statusCode == 200 || response.statusCode == 201;
      developer.log(success ? ' Registro exitoso' : ' Registro fallido');

      return success;
    } on TimeoutException {
      developer.log(' Timeout en registro');
      throw Exception(
          'Tiempo de espera agotado. ¿Está tu API C# corriendo en localhost:5000?');
    } catch (e) {
      developer.log(' Error en registro: $e');
      if (e.toString().contains('XMLHttpRequest') ||
          e.toString().contains('CORS')) {
        throw Exception('Error CORS: Debes configurar CORS en tu API C#');
      }
      throw Exception('Error al registrarse: ${e.toString()}');
    }
  }

  /// Obtener perfil autenticado
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) return null;

      developer.log(' Obteniendo perfil desde: $baseUrl/auth/profile');

      final response = await _client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      ).timeout(_timeout);

      developer.log(' Respuesta perfil - Código: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await storage.delete(key: 'jwt');
      }
      return null;
    } on TimeoutException {
      developer.log(' Timeout al obtener perfil');
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      developer.log(' Error al obtener perfil: $e');
      throw Exception('Error al obtener perfil: ${e.toString()}');
    }
  }

  /// Logout
  Future<void> logout() async {
    await storage.deleteAll();
  }

  /// Verificar si hay token válido
  Future<bool> hasValidToken() async {
    final token = await storage.read(key: 'jwt');
    return token != null && token.isNotEmpty;
  }

  void dispose() {
    _client.close();
  }
}
