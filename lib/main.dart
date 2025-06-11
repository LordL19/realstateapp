import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/viewmodels/profile_viewmodel.dart';
import 'package:realestate_app/viewmodels/auth_viewmodel.dart';
import 'package:realestate_app/views/splash_decision_view.dart'; // NUEVA VISTA

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar HTTP client globalmente
  HttpOverrides.global = MyHttpOverrides();

  // Manejo de errores global
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 30);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'RealEstate App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        home: const SplashDecisionView(), // ← Cambiado aquí
      ),
    );
  }
}
