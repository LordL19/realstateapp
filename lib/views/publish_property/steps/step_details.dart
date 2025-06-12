import 'dart:async';
import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';

class StepDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onTransactionChanged;

  const StepDetails({
    super.key,
    required this.formKey,
    required this.titleCtrl,
    required this.descCtrl,
    required this.onTypeChanged,
    required this.onTransactionChanged,
  });

  @override
  State<StepDetails> createState() => _StepDetailsState();
}

class _StepDetailsState extends State<StepDetails> {
  static const _propertyTypes = [
    'Casa',
    'Apartamento',
    'Terreno',
    'Local Comercial'
  ];
  static const _transactionTypes = ['Venta', 'Alquiler'];

  // Imagen + texto + métrica
  final List<List<String>> _promos = const [
    ['assets/images/house1.jpg', 'Casa más vista del mes', '1er lugar'],
    ['assets/images/house2.jpg', '200 tours agendados', '200+'],
    ['assets/images/house3.jpg', 'Calificación promedio ★4.8', '4.8★'],
    ['assets/images/house4.jpg', '50+ consultas recibidas', '50+'],
  ];
  late final PageController _promoCtrl;
  int _promoIndex = 0;
  Timer? _promoTimer;

  // Tips mejorados
  final List<String> _tips = const [
    'Destaca la iluminación natural en tu descripción.',
    'Menciona cercanía a transporte público o servicios.',
    'Resalta el tamaño de habitaciones y espacios exteriores.',
  ];
  late final PageController _tipsCtrl;
  int _tipIndex = 0;
  Timer? _tipTimer;

  String? _selectedType;
  String? _selectedTxn;

  @override
  void initState() {
    super.initState();
    // Carousel promo
    _promoCtrl = PageController(viewportFraction: 0.85);
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_promoIndex + 1) % _promos.length;
      _promoCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    // Debe actualizar _promoIndex al deslizar
    _promoCtrl.addListener(() {
      final page = _promoCtrl.page?.round() ?? 0;
      if (page != _promoIndex) setState(() => _promoIndex = page);
    });

    // Carousel tips
    _tipsCtrl = PageController();
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_tipIndex + 1) % _tips.length;
      _tipsCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
    _tipsCtrl.addListener(() {
      final page = _tipsCtrl.page?.round() ?? 0;
      if (page != _tipIndex) setState(() => _tipIndex = page);
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoCtrl.dispose();
    _tipTimer?.cancel();
    _tipsCtrl.dispose();
    super.dispose();
  }

  Widget _buildPromoTile(int i) {
    final img = _promos[i][0], caption = _promos[i][1], badge = _promos[i][2];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(img, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.onSecondaryContainer.withOpacity(0.6),
                  Colors.transparent
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: cs.primary, borderRadius: BorderRadius.circular(8)),
              child: Text(badge,
                  style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimary, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(caption,
                  style: tt.titleMedium?.copyWith(
                      color: cs.onPrimary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme, tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xs, AppSpacing.xxl, AppSpacing.xxl),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carousel promos
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _promoCtrl,
                itemCount: _promos.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                  child: _buildPromoTile(i),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            // Dot indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_promos.length, (i) {
                final sel = i == _promoIndex;
                return Container(
                  margin: const EdgeInsets.all(2),
                  width: sel ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: sel ? cs.primary : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.l),

            // Tips slider
            SizedBox(
              height: 60,
              child: PageView.builder(
                controller: _tipsCtrl,
                itemCount: _tips.length,
                itemBuilder: (_, i) => Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_tips[i],
                      style:
                          tt.bodyLarge?.copyWith(color: cs.onPrimaryContainer),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Use AppTextField without icons via Theme override
            Column(
              children: [
                AppTextField(
                  controller: widget.titleCtrl,
                  label: 'Título del anuncio',
                  validator: (v) =>
                      v!.isEmpty ? 'El título es obligatorio' : null,
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  controller: widget.descCtrl,
                  label: 'Descripción',
                  validator: (v) =>
                      v!.isEmpty ? 'La descripción es obligatoria' : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tipo de Propiedad'),
              items: _propertyTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedType = v);
                widget.onTypeChanged(v);
              },
              validator: (v) => v == null ? 'Selecciona un tipo' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<String>(
              value: _selectedTxn,
              decoration:
                  const InputDecoration(labelText: 'Tipo de Transacción'),
              items: _transactionTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedTxn = v);
                widget.onTransactionChanged(v);
              },
              validator: (v) => v == null ? 'Selecciona transacción' : null,
            ),
          ],
        ),
      ),
    );
  }
}
