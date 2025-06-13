// lib/views/publish_property/steps/step_details.dart

import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';

class StepDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onTransactionChanged;

  /// Valores iniciales (solo si vienes de editar)
  final String? initialType;
  final String? initialTxn;

  const StepDetails({
    super.key,
    required this.formKey,
    required this.titleCtrl,
    required this.descCtrl,
    required this.onTypeChanged,
    required this.onTransactionChanged,
    this.initialType,
    this.initialTxn,
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

  String? _selectedType;
  String? _selectedTxn;

  @override
  void initState() {
    super.initState();
    // Si vienen valores iniciales, precargamos
    _selectedType = widget.initialType;
    _selectedTxn = widget.initialTxn;
    // Notificamos al Wizard
    if (_selectedType != null) widget.onTypeChanged(_selectedType);
    if (_selectedTxn != null) widget.onTransactionChanged(_selectedTxn);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xs, AppSpacing.xxl, AppSpacing.xxl),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: widget.titleCtrl,
              label: 'Título del anuncio',
              validator: (v) => v!.isEmpty ? 'El título es obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              controller: widget.descCtrl,
              label: 'Descripción',
              validator: (v) =>
                  v!.isEmpty ? 'La descripción es obligatoria' : null,
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
