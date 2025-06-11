import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class FavoriteService {
  final http.Client _httpClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  FavoriteService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _defaultHeaders() async {
    final token = await _storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Obtiene la lista de IDs de propiedades marcadas como favoritas por el usuario.
  Future<List<String>> getFavoriteIds() async {
    final uri = Uri.parse('${ApiConfig.getBaseUrl(Microservice.favorites)}/favorites');
    final response = await _httpClient.get(uri, headers: await _defaultHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al obtener favoritos: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    // Cada elemento puede ser un objeto { idProperty: "uuid", ... }
    return data
        .map((item) => item['idProperty'] ?? item['propertyId'])
        .whereType<String>()
        .toList();
  }

  /// Marca una propiedad como favorita.
  Future<bool> addFavorite(String propertyId) async {
    final uri = Uri.parse('${ApiConfig.getBaseUrl(Microservice.favorites)}/favorites');
    final response = await _httpClient.post(
      uri,
      headers: await _defaultHeaders(),
      body: jsonEncode({'idProperty': propertyId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Error al agregar favorito: ${response.statusCode}');
  }

  /// Elimina una propiedad de favoritos.
  /// Según el Swagger solo se expone DELETE /favorites (sin path) con el cuerpo
  /// `{"idProperty": "uuid"}`. Adaptamos la llamada para reflejar esto.
  Future<bool> removeFavorite(String propertyId) async {
    final uri = Uri.parse('${ApiConfig.getBaseUrl(Microservice.favorites)}/favorites');
    // El microservicio no expone DELETE. Se usa POST nuevamente para "des-favorito",
    // el backend se encarga de quitar si ya existe.
    final response = await _httpClient.post(
      uri,
      headers: await _defaultHeaders(),
      body: jsonEncode({'idProperty': propertyId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Error al eliminar favorito: ${response.statusCode}');
  }
} 