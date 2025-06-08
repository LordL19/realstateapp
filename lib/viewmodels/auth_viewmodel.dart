import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;

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

  void clearError() {
    _setError(null);
  }

  /// LOGIN
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _setError("Email y contraseña son requeridos");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final token = await _authService.login(email, password);
      
      if (token != null) {
        return true;
      } else {
        _setError("Email o contraseña inválidos");
        return false;
      }
    } catch (e) {
      _setError(e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : "Error de conexión");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// REGISTRO COMPLETO
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
    _setLoading(true);
    _setError(null);

    try {
      final success = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        city: city,
        country: country,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (!success) {
        _setError("Error al registrarse. Intenta nuevamente.");
      }
      
      return success;
    } catch (e) {
      _setError(e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : "Error al registrarse");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
