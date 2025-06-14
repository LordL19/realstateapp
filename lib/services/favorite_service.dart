import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class FavoriteService {
  final http.Client _httpClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  FavoriteService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _defaultHeaders() async {
    final token = await _storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Obtiene la lista de IDs de propiedades marcadas como favoritas por el usuario.
  Future<List<String>> getFavoriteIds() async {
    final uri =
        Uri.parse('${ApiConfig.getBaseUrl(Microservice.favorites)}/favorites');
    debugPrint('Solicitando lista de favoritos');
    final response =
        await _httpClient.get(uri, headers: await _defaultHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al obtener favoritos: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final ids = data
        .map((item) => item['idProperty'] ?? item['propertyId'])
        .whereType<String>()
        .toList();
    return ids;
  }

  /// Marca una propiedad como favorita.
  /// El mismo endpoint también sirve para quitar favoritos si ya existe
  Future<bool> addFavorite(String propertyId) async {
    final uri =
        Uri.parse('${ApiConfig.getBaseUrl(Microservice.favorites)}/favorites');
    final response = await _httpClient.post(
      uri,
      headers: await _defaultHeaders(),
      body: jsonEncode({'idProperty': propertyId, 'propertyId': propertyId}),
    );

    debugPrint(
        '⭐ Respuesta del servidor: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Error al agregar favorito: ${response.statusCode}');
  }

  Future<bool> removeFavorite(String propertyId) async {
    final base = ApiConfig.getBaseUrl(Microservice.favorites);
    final deleteUri = Uri.parse('$base/favorites/$propertyId');

    final deleteResp =
        await _httpClient.delete(deleteUri, headers: await _defaultHeaders());

    if (deleteResp.statusCode == 200 || deleteResp.statusCode == 204) {
      debugPrint('DELETE favorito ok');
      return true;
    }

    return addFavorite(propertyId);
  }
}
