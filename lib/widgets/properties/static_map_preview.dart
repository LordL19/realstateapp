// lib/widgets/properties/static_map_preview.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class StaticMapPreview extends StatelessWidget {
  final LatLng latLng;
  const StaticMapPreview({super.key, required this.latLng});

  @override
  Widget build(BuildContext context) {
    // mete tu token en algún lugar seguro o en Theme/Config
    const token =
        'pk.eyJ1IjoiZGllZ29hcHYxMiIsImEiOiJjbWJzdGlwN2YwN3JhMmxxMHBpMTFvaW0wIn0.1GSG6G2_uKkDEqCnnnyxuQ';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/'
        '${latLng.longitude},${latLng.latitude},15,0/640x320'
        '?access_token=$token',
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.map, size: 48)),
        ),
      ),
    );
  }
}
