import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/visit_history_model.dart';
import '../models/create_visit_history_request.dart';

class VisitHistoryService {
  final http.Client _httpClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = ApiConfig.getBaseUrl(Microservice.favorites);

  VisitHistoryService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Records a new visit history entry when a user clicks on a property
  Future<bool> recordVisit(CreateVisitHistoryRequest request) async {
    final uri = Uri.parse('$_baseUrl/visit-history');
    final response = await _httpClient.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    throw Exception('Error al registrar visita: ${response.statusCode}');
  }

  /// Gets visit history for the current user
  Future<List<VisitHistory>> getUserVisitHistory() async {
    final uri = Uri.parse('$_baseUrl/visit-history');
    final response = await _httpClient.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener historial de visitas: ${response.statusCode}');
    }

    final dynamic data = jsonDecode(response.body);
    if (data is List) {
      return data.map((item) => VisitHistory.fromJson(item)).toList();
    }
    return [];
  }

  /// Gets visit history for a specific property
  Future<List<VisitHistory>> getPropertyVisitHistory(String propertyId) async {
    final uri = Uri.parse('$_baseUrl/visit-history/stats/$propertyId');
    final response = await _httpClient.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener historial de visitas de la propiedad: ${response.statusCode}');
    }
    
    final dynamic decodedBody = jsonDecode(response.body);

    if (decodedBody is Map<String, dynamic>) {
      // Look for a list in common keys
      final dynamic historyData = decodedBody['visits'] ?? decodedBody['history'] ?? decodedBody['data'];
      
      if (historyData is List) {
        return historyData.map((item) => VisitHistory.fromJson(item)).toList();
      }
      // If the map itself represents a single history item
      if(decodedBody.containsKey('idProperty')) {
        return [VisitHistory.fromJson(decodedBody)];
      }

      return []; // Return empty list if no known key or valid structure found
    } else if (decodedBody is List) {
      return decodedBody.map((item) => VisitHistory.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  /// Gets filtered visit history
  Future<List<VisitHistory>> getFilteredVisitHistory(Map<String, String> filters) async {
    final uri = Uri.parse('$_baseUrl/visit-history/filter').replace(
      queryParameters: filters,
    );
    
    final response = await _httpClient.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener historial filtrado: ${response.statusCode}');
    }

    final dynamic data = jsonDecode(response.body);
    if (data is List) {
      return data.map((item) => VisitHistory.fromJson(item)).toList();
    }
    return [];
  }

  /// Gets visit recommendations based on user's history
  Future<List<VisitHistory>> getRecommendations() async {
    final uri = Uri.parse('$_baseUrl/visit-history/recommendations');
    final response = await _httpClient.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener recomendaciones: ${response.statusCode}');
    }

    final dynamic data = jsonDecode(response.body);
    if (data is List) {
      return data.map((item) => VisitHistory.fromJson(item)).toList();
    }
    return [];
  }
} 