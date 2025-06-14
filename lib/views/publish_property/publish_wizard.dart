// lib/views/publish_property/publish_wizard.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/create_property_input.dart';
import '../../models/property.dart';
import '../../models/review_mode.dart';
import '../../theme/theme.dart';
import '../../viewmodels/property_viewmodel.dart';

import 'steps/step_details.dart';
import 'steps/step_location.dart';
import 'steps/step_features.dart';
import 'steps/step_gallery.dart';
import 'steps/step_review.dart';

class PublishWizard extends StatefulWidget {
  /// Si [property] es `null` el wizard crea, si no, edita.
  final Property? property;
  const PublishWizard({super.key, this.property});

  @override
  State<PublishWizard> createState() => _PublishWizardState();
}

class _PublishWizardState extends State<PublishWizard> {
  /* ────────────────  controladores  ──────────────── */
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? propertyType, transactionType;

  String? country, city;
  final addressCtrl = TextEditingController();
  LatLng? latlng;

  final priceCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final builtAreaCtrl = TextEditingController();
  int? bedrooms;
  double? price;
  int? area, builtArea;

  List<String> photoUrls = [];

  /* ────────────────  STATE  ──────────────── */
  final _keys = List.generate(5, (_) => GlobalKey<FormState>());
  int _step = 0;
  bool _loading = false;

  bool get _isEdit => widget.property != null;
  Property get _prop => widget.property!;

  /* ────────────────  INIT  ──────────────── */
  @override
  void initState() {
    super.initState();
    if (_isEdit) _hydrateFromProperty();
  }

  void _hydrateFromProperty() {
    titleCtrl.text = _prop.title;
    descCtrl.text = _prop.description ?? '';
    propertyType = _prop.propertyType;
    transactionType = _prop.transactionType;

    country = _prop.country;
    city = _prop.city;
    addressCtrl.text = _prop.address ?? '';

    priceCtrl.text = _prop.price.toStringAsFixed(0);
    areaCtrl.text = _prop.area.toString();
    builtAreaCtrl.text = _prop.builtArea.toString();
    bedrooms = _prop.bedrooms;

    price = _prop.price;
    area = _prop.area;
    builtArea = _prop.builtArea;

    photoUrls = List.from(_prop.photos);

    if (_prop.latitude != null && _prop.longitude != null) {
      latlng = LatLng(_prop.latitude!, _prop.longitude!);
    }
  }

  /* ────────────────  NAVEGACIÓN  ──────────────── */
  void _next() async {
    // valida solo si el paso actual tiene Form
    if (_keys[_step].currentState?.validate() == false) return;

    switch (_step) {
      case 1: // Ubicación
        if (latlng == null) {
          _snack('Marca la ubicación en el mapa');
          return;
        }
        break;
      case 2: // Características
        price = double.tryParse(priceCtrl.text);
        area = int.tryParse(areaCtrl.text);
        builtArea = int.tryParse(builtAreaCtrl.text);
        if ([price, area, builtArea].contains(null) ||
            price! <= 0 ||
            area! <= 0 ||
            builtArea! <= 0) {
          _snack('Corrige los valores numéricos');
          return;
        }
        break;
      case 3: // Galería
        if (photoUrls.isEmpty) {
          _snack('Añade al menos una foto');
          return;
        }
        break;
      case 4: // Revisión
        await _submit();
        return;
    }
    setState(() => _step++);
  }

  void _back() => setState(() => _step = _step > 0 ? _step - 1 : 0);

  /* ────────────────  SUBMIT  ──────────────── */
  Future<void> _submit() async {
    setState(() => _loading = true);

    final input = CreatePropertyInput(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      city: city!,
      country: country!,
      propertyType: propertyType!,
      transactionType: transactionType!,
      price: price!,
      area: area!,
      builtArea: builtArea!,
      bedrooms: bedrooms!,
      photos: photoUrls,
      latitude: latlng!.latitude,
      longitude: latlng!.longitude,
    );

    final vm = context.read<PropertyViewModel>();
    final ok = _isEdit
        ? await vm.updateProperty(_prop.idProperty, input)
        : await vm.createProperty(input);

    // Refrescar las listas para que otras vistas se sincronicen inmediatamente
    if (ok) await vm.fetchProperties();

    setState(() => _loading = false);
    _snack(ok ? 'Guardado' : 'Error al guardar', error: !ok);
    if (ok && mounted) {
      if (_isEdit) {
        // Cierra el wizard y la pantalla de detalle para volver a la lista
        Navigator.of(context).pop(); // Wizard
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Detalle
        }
      } else {
        Navigator.pop(context);
      }
    }
  }

  /* ────────────────  UI  ──────────────── */
  @override
  Widget build(BuildContext context) {
    final pages = [
      StepDetails(
        formKey: _keys[0],
        titleCtrl: titleCtrl,
        descCtrl: descCtrl,
        onTypeChanged: (v) => propertyType = v,
        onTransactionChanged: (v) => transactionType = v,
        initialType: propertyType,
        initialTxn: transactionType,
      ),
      StepLocation(
        formKey: _keys[1],
        country: country,
        city: city,
        addressCtrl: addressCtrl,
        onCountryChanged: (c) => setState(() {
          country = c;
          city = null;
        }),
        onCityChanged: (c) => setState(() => city = c),
        onLocationSelected: (p) => latlng = p,
        initialLatLng: latlng,
      ),
      StepFeatures(
        formKey: _keys[2],
        priceCtrl: priceCtrl,
        areaCtrl: areaCtrl,
        builtAreaCtrl: builtAreaCtrl,
        bedrooms: bedrooms,
        onBedroomsChanged: (v) => setState(() => bedrooms = v),
        city: city,
      ),
      StepGallery(
        initialUrls: photoUrls,
        onChanged: (urls) => photoUrls = urls,
      ),
      StepReview(
        data: ReviewData(
          title: titleCtrl.text,
          desc: descCtrl.text,
          type: propertyType,
          txn: transactionType,
          country: country,
          city: city,
          address: addressCtrl.text,
          price: price,
          area: area,
          built: builtArea,
          beds: bedrooms,
          photos: photoUrls,
          latLng: latlng,
        ),
      ),
    ];

    const stepTitles = [
      'Detalles',
      'Ubicación',
      'Características',
      'Galería',
      'Revisión'
    ];
    final progress = (_step + 1) / pages.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /* ---------- HEADER ---------- */
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xs,
                  AppSpacing.xxl, AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_step == 0)
                    CircleAvatar(
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(stepTitles[_step],
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
            /* ---------- PAGE ---------- */
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.l),
                child: pages[_step],
              ),
            ),
          ],
        ),
      ),
      /* ---------- FOOTER ---------- */
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.m,
            0,
            AppSpacing.m,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
          ),
          child: Row(
            children: [
              if (_step > 0)
                FilledButton.tonalIcon(
                  onPressed: _loading ? null : _back,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Atrás'),
                  style:
                      FilledButton.styleFrom(minimumSize: const Size(120, 48)),
                ),
              if (_step == 0) const SizedBox(width: 120),
              const Spacer(),
              SizedBox(
                width: 140,
                height: 48,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _next,
                        icon: Icon(_step == pages.length - 1
                            ? Icons.check
                            : Icons.arrow_forward),
                        label: Text(_step == pages.length - 1
                            ? (_isEdit ? 'Guardar' : 'Publicar')
                            : 'Siguiente'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* -------- snack helper -------- */
  void _snack(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m),
        backgroundColor: error ? Colors.red : null,
      ));

  @override
  void dispose() {
    for (final c in [
      titleCtrl,
      descCtrl,
      addressCtrl,
      priceCtrl,
      areaCtrl,
      builtAreaCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
