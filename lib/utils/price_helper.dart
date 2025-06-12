import 'package:flutter/material.dart';

class PriceHelper {
  /// Datos mock (USD por m²)
  static const Map<String, RangeValues> _priceTable = {
    'Santa Cruz': RangeValues(600, 1200),
    'La Paz': RangeValues(500, 950),
    'Cochabamba': RangeValues(450, 800),
    'Buenos Aires': RangeValues(1400, 2500),
    'Madrid': RangeValues(3000, 5000),
    // … añade más ciudades
  };

  /// Devuelve rango sugerido; si no existe, rango (0,0)
  static RangeValues suggestedPrice(String city) =>
      _priceTable[city] ?? const RangeValues(0, 0);

  /// Formatea el rango para mostrar en UI (“600-1200 USD/m²”)
  static String formatRange(RangeValues range) =>
      '${range.start.toInt()}-${range.end.toInt()} USD/m²';
}
