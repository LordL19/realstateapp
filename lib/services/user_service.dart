import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_info_model.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final http.Client _httpClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = ApiConfig.getBaseUrl(Microservice.users);

  UserService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Gets current user information
  Future<UserInfo> getCurrentUser() async {
    final uri = Uri.parse('$_baseUrl/user/me');
    final response = await _httpClient.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener información del usuario: ${response.statusCode}');
    }

    return UserInfo.fromJson(jsonDecode(response.body));
  }

  /// Gets user information by ID
  Future<UserInfo> getUserById(String userId) async {
    final uri = Uri.parse('$_baseUrl/user/$userId/email');
    
    debugPrint("Fetching user info for $userId from $uri");
    
    final response = await _httpClient.get(
      uri,
      headers: await _getHeaders(),
    );

    debugPrint("Response status: ${response.statusCode}");
    if (response.statusCode != 200) {
      debugPrint("Response body: ${response.body}");
      throw Exception('Error al obtener información del usuario ID $userId: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    debugPrint("User data: $data");
    
    // If the endpoint only returns email, create a minimal UserInfo
    if (data is Map<String, dynamic> && data.containsKey('email')) {
      return UserInfo(
        id: userId,
        firstName: 'Usuario',
        lastName: userId.substring(0, min(userId.length, 6)),
        email: data['email'],
      );
    }
    
    return UserInfo.fromJson(data);
  }

  /// Gets a cached map of user IDs to UserInfo to minimize API calls
  Future<Map<String, UserInfo>> getUsersCache(List<String> userIds) async {
    final Map<String, UserInfo> cache = {};
    
    debugPrint("Fetching info for ${userIds.length} users");
    
    // Add current user to cache first
    try {
      final currentUser = await getCurrentUser();
      cache[currentUser.id] = currentUser;
      debugPrint("Added current user to cache: ${currentUser.id}");
    } catch (e) {
      debugPrint("Error getting current user: $e");
      // Continue even if current user can't be fetched
    }
    
    // Fetch any remaining users
    for (final userId in userIds) {
      if (!cache.containsKey(userId)) {
        try {
          debugPrint("Fetching user $userId");
          cache[userId] = await getUserById(userId);
        } catch (e) {
          debugPrint("Error fetching user $userId: $e");
          // If we can't get info, create a placeholder
          cache[userId] = UserInfo(
            id: userId,
            firstName: 'Usuario',
            lastName: userId.substring(0, min(userId.length, 6)),
            email: '',
          );
        }
      }
    }
    
    debugPrint("Returning cache with ${cache.length} users");
    return cache;
  }
  
  // Helper function for min
  int min(int a, int b) => a < b ? a : b;
} 