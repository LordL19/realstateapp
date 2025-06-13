// lib/views/publish_property/steps/step_location.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/utils/city_mapper.dart';

class StepLocation extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? country;
  final String? city;
  final TextEditingController addressCtrl;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<LatLng>? onLocationSelected;

  /// ← NUEVO: coordenada opcional al inicializar (por ejemplo, en edición)
  final LatLng? initialLatLng;

  const StepLocation({
    super.key,
    required this.formKey,
    required this.country,
    required this.city,
    required this.addressCtrl,
    required this.onCountryChanged,
    required this.onCityChanged,
    this.onLocationSelected,
    this.initialLatLng, // ← añadido
  });

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  static const _initialCenter = LatLng(-17.7833, -63.1821);

  LatLng? _picked;
  bool _geoLoading = false;

  final _mapboxToken =
      'pk.eyJ1IjoiZGllZ29hcHYxMiIsImEiOiJjbWJzdGlwN2YwN3JhMmxxMHBpMTFvaW0wIn0.1GSG6G2_uKkDEqCnnnyxuQ';
  final _styleId = 'mapbox/streets-v11';

  @override
  void initState() {
    super.initState();
    // ← SI nos pasan una coordenada inicial, la marcamos y notificamos al padre:
    if (widget.initialLatLng != null) {
      _picked = widget.initialLatLng;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLocationSelected?.call(_picked!);
      });
    }
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _geoLoading = true);
    try {
      final url = Uri.parse('https://api.mapbox.com/geocoding/v5/mapbox.places/'
          '${pos.longitude},${pos.latitude}.json'
          '?access_token=$_mapboxToken&limit=1&language=es');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>;
        if (features.isNotEmpty) {
          final name = features.first['place_name'] as String?;
          if (name != null) widget.addressCtrl.text = name;
        }
      }
    } catch (_) {
      // silencioso
    } finally {
      if (mounted) setState(() => _geoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xs,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tip UX
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Para mejores resultados, selecciona la ubicación con ±20 m de precisión.',
                style: tt.bodyMedium!.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            // País
            DropdownButtonFormField<String>(
              value: widget.country,
              decoration: const InputDecoration(labelText: 'País'),
              items: CityMapper.countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: widget.onCountryChanged,
              validator: (v) => v == null ? 'Selecciona un país' : null,
            ),
            const SizedBox(height: AppSpacing.m),

            // Ciudad
            DropdownButtonFormField<String>(
              value: widget.city,
              decoration: const InputDecoration(labelText: 'Ciudad'),
              items: CityMapper.citiesOf(widget.country ?? '')
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: widget.onCityChanged,
              validator: (v) => v == null ? 'Selecciona una ciudad' : null,
            ),
            const SizedBox(height: AppSpacing.m),

            // Dirección exacta
            TextFormField(
              controller: widget.addressCtrl,
              decoration: const InputDecoration(labelText: 'Dirección exacta'),
              validator: (v) =>
                  v!.trim().isEmpty ? 'La dirección es obligatoria' : null,
            ),
            const SizedBox(height: AppSpacing.l),

            // Mapa real
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    // ← aquí usamos el picked (o el centro por defecto)
                    initialCenter: _picked ?? _initialCenter,
                    initialZoom: 13,
                    onTap: (_, latlng) {
                      setState(() => _picked = latlng);
                      widget.onLocationSelected?.call(latlng);
                      _reverseGeocode(latlng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/$_styleId/tiles/256/{z}/{x}/{y}@2x'
                          '?access_token=$_mapboxToken',
                      additionalOptions: {
                        'accessToken': _mapboxToken,
                        'id': _styleId,
                      },
                    ),
                    if (_picked != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _picked!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Indicador carga reverse-geocode
            if (_geoLoading)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      'Obteniendo dirección…',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

            // Mensaje tocar para marcar
            if (_picked == null && !_geoLoading)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s),
                child: Text(
                  'Toca el mapa para fijar la ubicación exacta.',
                  style: tt.bodySmall?.copyWith(color: cs.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
