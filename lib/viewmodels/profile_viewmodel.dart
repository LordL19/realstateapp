import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'dart:developer' as developer;

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      if (error != null) notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    _setError(null);
    developer.log('📡 Llamando a fetchProfile()...');

    try {
      final profileData = await _profileService.getProfile();
      if (profileData == null) {
        developer.log('❌ Perfil devuelto como null');
        _setError("No se pudo cargar el perfil");
        _profile = null;
        return;
      }

      developer.log('🎯 Perfil asignado correctamente');
      _profile = profileData;
    } catch (e) {
      developer.log('❌ Error capturado en fetchProfile(): $e');
      _setError(e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : "Error al cargar perfil");
      _profile = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _profileService.dispose();
    super.dispose();
  }
}
