// lib/views/publish_property/steps/step_features.dart
import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/utils/price_helper.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';

class StepFeatures extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController builtAreaCtrl;
  final int? bedrooms;
  final ValueChanged<int?> onBedroomsChanged;
  final String? city;

  const StepFeatures({
    super.key,
    required this.formKey,
    required this.priceCtrl,
    required this.areaCtrl,
    required this.builtAreaCtrl,
    required this.bedrooms,
    required this.onBedroomsChanged,
    required this.city,
  });

  @override
  State<StepFeatures> createState() => _StepFeaturesState();
}

class _StepFeaturesState extends State<StepFeatures> {
  final List<int> _staticPresets = [50000, 100000, 250000, 500000];
  late final TextEditingController _bedsCtrl;

  RangeValues get _range => PriceHelper.suggestedPrice(widget.city ?? '');

  List<int> get _dynamicPresets {
    final a = int.tryParse(widget.areaCtrl.text) ?? 0;
    if (a == 0 || _range.start == 0) return [];
    final min = (a * _range.start).round();
    final max = (a * _range.end).round();
    return [min, max];
  }

  void _applyPrice(int v) =>
      setState(() => widget.priceCtrl.text = v.toString());

  @override
  void initState() {
    super.initState();
    widget.areaCtrl.addListener(() => setState(() {}));
    _bedsCtrl = TextEditingController(
      text: widget.bedrooms != null && widget.bedrooms! > 10
          ? widget.bedrooms.toString()
          : '10',
    );
    _bedsCtrl.addListener(() {
      final v = int.tryParse(_bedsCtrl.text);
      if (v != null && v > 10) widget.onBedroomsChanged(v);
    });
  }

  @override
  void dispose() {
    widget.areaCtrl.removeListener(() {});
    _bedsCtrl.dispose();
    super.dispose();
  }

  String _formatK(int n) =>
      n >= 1000 ? '${(n / 1000).round()} K' : n.toString();

  void _incDec(TextEditingController c, int delta) {
    final v = int.tryParse(c.text) ?? 0;
    final nv = (v + delta).clamp(0, 10000);
    setState(() => c.text = nv.toString());
  }

  Widget _numberWithStepper({
    required TextEditingController controller,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: controller,
            label: label,
            validator: (v) =>
                (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'Valor inválido',
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => _incDec(controller, 5),
            ),
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () => _incDec(controller, -5),
            ),
          ],
        ),
      ],
    );
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
            Text(
              'Datos técnicos de la propiedad.',
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Precio
            AppTextField(
              controller: widget.priceCtrl,
              label: 'Precio (USD)',
              validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                  ? null
                  : 'Precio inválido',
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              children: [..._staticPresets, ..._dynamicPresets].map((p) {
                final sel = widget.priceCtrl.text == p.toString();
                return ChoiceChip(
                  label: Text(_formatK(p)),
                  selected: sel,
                  showCheckmark: false,
                  onSelected: (_) => _applyPrice(p),
                  selectedColor: cs.primary,
                  labelStyle: TextStyle(
                    color: sel ? cs.onPrimary : cs.onSurface,
                  ),
                );
              }).toList(),
            ),
            if (widget.city != null && _range.start > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s),
                child: Text(
                  'Rango mercado ${widget.city}: '
                  '${PriceHelper.formatRange(_range)}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: AppSpacing.m),

            // Área total
            _numberWithStepper(
              controller: widget.areaCtrl,
              label: 'Área total (m²)',
            ),
            const SizedBox(height: AppSpacing.m),

            // Área construida
            _numberWithStepper(
              controller: widget.builtAreaCtrl,
              label: 'Área construida (m²)',
            ),
            const SizedBox(height: AppSpacing.m),

            // Habitaciones slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Habitaciones: ${widget.bedrooms ?? 1}',
                    style: tt.bodyMedium),
                Slider.adaptive(
                  value: (widget.bedrooms ?? 1).toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => widget.onBedroomsChanged(v.toInt()),
                ),
              ],
            ),

            // Input manual si >10
            if ((widget.bedrooms ?? 1) >= 10)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    controller: _bedsCtrl,
                    label: 'Habitaciones (manual)',
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 10) return 'Mayor o igual a 10';
                      return null;
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
