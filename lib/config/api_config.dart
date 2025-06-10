import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

enum Microservice {
  users,
  properties,
}

class ApiConfig {
  static String getBaseUrl(Microservice service) {
    String host;
    String scheme = 'http';

    // Determinar el host basado en la plataforma
    if (kIsWeb) {
      host = "localhost";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      host = "10.0.2.2";
    } else {
      // Para iOS o dispositivos físicos, deberás usar la IP de tu máquina.
      // Por ahora, usaremos localhost como placeholder.
      host = "localhost";
    }

    // Asignar el puerto y esquema según el microservicio
    switch (service) {
      case Microservice.users:
        return "$scheme://$host:5001";
      case Microservice.properties:
        // En web, usamos https porque el servidor redirige http
        if (kIsWeb) {
          scheme = 'https';
          return "$scheme://$host:5002";
        }
        return "$scheme://$host:5003";
      default:
        throw ArgumentError("Microservicio no soportado");
    }
  }

  static String getGraphQLEndpoint() {
    return "${getBaseUrl(Microservice.properties)}/graphql";
  }
} 