/// ---------------------------------------------------------------------------
/// city_mapper.dart  —  utilidades de localización
/// ---------------------------------------------------------------------------
class CityMapper {
  // Lista pública de países
  static const List<String> countries = [
    'Argentina',
    'Bolivia',
    'Chile',
    'Colombia',
    'Ecuador',
    'España',
    'México',
    'Perú',
    'Uruguay',
    'Venezuela',
  ];

  // Mapa público (ciudades ordenadas alfabéticamente)
  static const Map<String, List<String>> citiesByCountry = {
    'Argentina': ['Buenos Aires', 'Córdoba', 'Rosario'],
    'Bolivia': ['La Paz', 'Santa Cruz', 'Cochabamba'],
    'Chile': ['Santiago', 'Valparaíso', 'Concepción'],
    'Colombia': ['Bogotá', 'Medellín', 'Cali'],
    'Ecuador': ['Quito', 'Guayaquil', 'Cuenca'],
    'España': ['Madrid', 'Barcelona', 'Valencia'],
    'México': ['Ciudad de México', 'Guadalajara', 'Monterrey'],
    'Perú': ['Lima', 'Arequipa', 'Cusco'],
    'Uruguay': ['Montevideo', 'Punta del Este', 'Salto'],
    'Venezuela': ['Caracas', 'Maracaibo', 'Valencia'],
  };

  /// Devuelve `true` si `city` pertenece a `country`.
  static bool isCityValid(String city, String country) =>
      (citiesByCountry[country] ?? []).contains(city);

  /// Devuelve lista de ciudades de `country` o lista vacía.
  static List<String> citiesOf(String country) =>
      List.unmodifiable(citiesByCountry[country] ?? []);

  /// Normaliza entradas del formulario (trim + capitalización básica).
  static String normalize(String input) => input.trim().isEmpty
      ? ''
      : input.trim()[0].toUpperCase() + input.trim().substring(1).toLowerCase();
}
