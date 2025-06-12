import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

enum Microservice {
  users,
  properties,
  visits,
  favorites,
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
      host =
          "localhost"; // Puedes reemplazar con la IP de tu máquina si es necesario
    }

    // Asignar el puerto según el microservicio
    int port;
    switch (service) {
      case Microservice.users:
        port = 5001;
        break;
      case Microservice.properties:
        port = 5002;
        break;
      case Microservice.visits:
        port = 5003;
        break;
      case Microservice.favorites:
        port = 5004;
        break;
    }

    return "$scheme://$host:$port";
  }

  static String getGraphQLEndpoint() {
    return "${getBaseUrl(Microservice.properties)}/graphql";
  }
}
