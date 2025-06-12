import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Se mantiene por si se necesita en el futuro
import '../models/user_profile.dart';

class ProfileService {
  static final _client = http.Client();
  final baseUrl = "http://10.26.7.251:63063"; // Asegúrate de que esta IP esté actualizada
  final storage = const FlutterSecureStorage();
  
  static const _timeout = Duration(seconds: 15);

  Future<UserProfile?> getProfile() async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) {
        developer.log(' No hay token almacenado, no se puede obtener perfil.');
        return null;
      }

      final url = '$baseUrl/user/profile';
      developer.log(' Enviando petición GET a: $url');
      developer.log(' Token: $token');

      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      developer.log(' Código de respuesta: ${response.statusCode}');
      developer.log(' Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('Perfil recibido correctamente: $data');
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        developer.log(' Token inválido o expirado, eliminando...');
        await storage.delete(key: 'jwt');
      } else {
        developer.log('Error HTTP: ${response.statusCode}');
      }
      return null;
    } on TimeoutException {
      developer.log(' Timeout al obtener perfil');
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      developer.log(' Error al obtener perfil: $e');
      throw Exception('Error al cargar perfil: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
