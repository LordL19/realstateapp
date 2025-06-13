// lib/views/my_properties/widgets/property_filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme.dart';
import '../../../viewmodels/property_viewmodel.dart';

class PropertyFilterSheet extends StatefulWidget {
  const PropertyFilterSheet({super.key});

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  // ── controllers ──
  final _searchC = TextEditingController(),
      _bedC = TextEditingController(),
      _areaC = TextEditingController(),
      _builtC = TextEditingController(),
      _minPC = TextEditingController(),
      _maxPC = TextEditingController();

  // dropdowns locales
  String? _searchType;
  String? _country;
  String? _city;
  String? _propType;

  @override
  void initState() {
    super.initState();
    final vm = context.read<PropertyViewModel>();

    _searchC.text = vm.searchQuery;
    _bedC.text = vm.minBedrooms?.toString() ?? '';
    _areaC.text = vm.minTotalArea?.toString() ?? '';
    _builtC.text = vm.minBuiltArea?.toString() ?? '';
    _minPC.text = vm.minPrice?.toString() ?? '';
    _maxPC.text = vm.maxPrice?.toString() ?? '';

    _searchType = vm.searchType;
    _country = vm.selectedCountry;
    _city = vm.selectedCity;
    _propType = vm.selectedPropertyType;
  }

  @override
  void dispose() {
    // Los controladores…
    _searchC.dispose();
    _bedC.dispose();
    _areaC.dispose();
    _builtC.dispose();
    _minPC.dispose();
    _maxPC.dispose();

    // 🔔 Emitimos la notificación final
    context.read<PropertyViewModel>().refresh(); // << sin warnings

    super.dispose();
  }

  /* ── helpers ─────────────────────────────────────────── */
  Widget _numField(TextEditingController c, String lbl,
          ValueChanged<String?> onChanged) =>
      TextField(
        controller: c,
        decoration: InputDecoration(labelText: lbl),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
      );

  Widget _priceField(TextEditingController c, String lbl,
          ValueChanged<String?> onChanged) =>
      TextField(
        controller: c,
        decoration: InputDecoration(labelText: lbl, prefixText: '\$'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        ],
        onChanged: onChanged,
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PropertyViewModel>();
    final cs = Theme.of(context).colorScheme;

    return FractionallySizedBox(
      heightFactor: .6,
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl, AppSpacing.l, AppSpacing.xxl, AppSpacing.xxl),
          child: ListView(
            children: [
              /* agarradera */
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Filtros & búsqueda',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.l),

              /* búsqueda + tipo */
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchC,
                      decoration: const InputDecoration(labelText: 'Buscar…'),
                      onChanged: vm.updateSearchQuery,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Por'),
                      value: _searchType,
                      items: const ['Nombre', 'Zona', 'País', 'Ciudad']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _searchType = v);
                        vm.updateSearchType(v!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              /* país / ciudad */
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'País'),
                value: _country,
                items: vm.countries
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _country = v;
                    _city = null;
                  });
                  vm.updateCountry(v);
                },
              ),
              if (_country != null) ...[
                const SizedBox(height: AppSpacing.s),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                  value: _city,
                  items: vm
                      .getCitiesForCountry(_country)
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _city = v);
                    vm.updateCity(v);
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.m),

              /* tipo propiedad */
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Tipo de Propiedad'),
                value: _propType,
                items: const [
                  'Casa',
                  'Apartamento',
                  'Terreno',
                  'Local Comercial'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _propType = v);
                  vm.updatePropertyTypeFilter(v);
                },
              ),
              const SizedBox(height: AppSpacing.m),

              /* rango precio */
              Row(
                children: [
                  Expanded(
                      child: _priceField(
                          _minPC, 'Precio mín.', vm.updateMinPrice)),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                      child: _priceField(
                          _maxPC, 'Precio máx.', vm.updateMaxPrice)),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              /* numéricos */
              Row(
                children: [
                  Expanded(
                      child: _numField(_bedC, 'Hab.', vm.updateMinBedrooms)),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                      child:
                          _numField(_areaC, 'Área m²', vm.updateMinTotalArea)),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                      child: _numField(
                          _builtC, 'Const. m²', vm.updateMinBuiltArea)),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

/* acciones */
              Row(
                children: [
                  // ------------- LIMPIAR TODO -------------
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Limpiar'),
                      onPressed: () {
                        final vm = context.read<PropertyViewModel>();

                        // 1) Resetear ViewModel
                        vm.clearFilters();

                        // 2) Vaciar controllers
                        for (final c in [
                          _searchC,
                          _bedC,
                          _areaC,
                          _builtC,
                          _minPC,
                          _maxPC,
                        ]) {
                          c.clear();
                        }

                        // 3) Resetear selects locales
                        setState(() {
                          _searchType = null;
                          _country = null;
                          _city = null;
                          _propType = null;
                        });
                      },
                    ),
                  ),

                  const Spacer(),

                  // ------------- CERRAR -------------
                  SizedBox(
                    width: 140,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
