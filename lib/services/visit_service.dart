import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:realestate_app/config/api_config.dart';
import 'dart:convert';

import '../models/visit_model.dart';
import '../models/create_visit_request.dart';

class VisitService {
  final String _baseUrl = ApiConfig.getBaseUrl(Microservice.visits);
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'jwt');
  }

  Future<List<Visit>> getMyVisits() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/visits/my-visits'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener tus visitas');
    }
  }

  Future<List<Visit>> getVisitsByOwner() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/visits/owner'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener visitas como propietario');
    }
  }

  Future<List<Visit>> getVisitsByProperty(String propertyId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/visits/property/$propertyId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener visitas de la propiedad');
    }
  }

  Future<void> createVisit(CreateVisitRequest visit) async {
    final token = await storage.read(key: 'jwt');
    final response = await http.post(
      Uri.parse('$_baseUrl/visits'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(visit.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al crear la visita');
    }
  }

  Future<void> updateStatus(String idVisitRequest, String newStatus) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/visits/$idVisitRequest/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "idVisitRequest": idVisitRequest,
        "newStatus": newStatus,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('No se pudo actualizar el estado');
    }
  }
}
