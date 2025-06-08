import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

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

    try {
      _profile = await _profileService.getProfile();
      if (_profile == null) {
        _setError("No se pudo cargar el perfil");
      }
    } catch (e) {
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