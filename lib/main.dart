import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/config/api_config.dart';
import 'package:realestate_app/services/user_service.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/viewmodels/auth_viewmodel.dart';
import 'package:realestate_app/viewmodels/favorite_viewmodel.dart';
import 'package:realestate_app/viewmodels/profile_viewmodel.dart';
import 'package:realestate_app/viewmodels/property_viewmodel.dart';
import 'package:realestate_app/viewmodels/visits_viewmodel.dart';
import 'package:realestate_app/viewmodels/visit_history_viewmodel.dart';
import 'package:realestate_app/views/splash_decision_view.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

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
    const storage = FlutterSecureStorage();

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await storage.read(key: 'jwt');
        return token != null ? 'Bearer $token' : null;
      },
    );

    final HttpLink httpLink = HttpLink(
      ApiConfig.getGraphQLEndpoint(),
    );

    final Link link = authLink.concat(httpLink);

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(
              create: (_) => PropertyViewModel(client: client.value)..fetchProperties()),
          ChangeNotifierProvider(create: (_) => VisitViewModel()),
          ChangeNotifierProvider(create: (_) => VisitHistoryViewModel()),
          ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
          Provider(
            create: (_) => UserService(),
          ),
        ],
        child: MaterialApp(
          title: 'RealEstate App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeMode,
          home: const SplashDecisionView(),
        ),
      ),
    );
  }
}
