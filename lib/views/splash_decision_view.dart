import 'package:flutter/material.dart';
import 'package:realestate_app/services/auth_service.dart';
import 'package:realestate_app/views/login_view.dart';
import 'package:realestate_app/views/main_tab_view.dart';
import 'package:realestate_app/views/profile_view.dart'; // o HomeView si prefieres

class SplashDecisionView extends StatefulWidget {
  const SplashDecisionView({super.key});

  @override
  State<SplashDecisionView> createState() => _SplashDecisionViewState();
}

class _SplashDecisionViewState extends State<SplashDecisionView> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final hasToken = await _authService.hasValidToken();
    if (!mounted) return;

    if (hasToken) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainTabView()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
