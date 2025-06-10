import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/viewmodels/profile_viewmodel.dart';
import 'config/api_config.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para el cache de GraphQL
  await initHiveForFlutter();
  
  // Configurar HTTP client globalmente
  HttpOverrides.global = MyHttpOverrides();
  
  // Manejo de errores global
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 30);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

    // Encadenamos el link de autenticación con el link HTTP
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
      ],
      child: MaterialApp(
        title: 'RealEstate App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LoginView(),
        ),
      ),
    );
  }
}