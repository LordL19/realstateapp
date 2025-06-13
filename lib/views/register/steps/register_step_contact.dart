import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/viewmodels/property_viewmodel.dart';

class ContactSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phone;
  final String? city;
  final String? country;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;

  const ContactSection({
    super.key,
    required this.formKey,
    required this.phone,
    required this.city,
    required this.country,
    required this.onCountryChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Contacto', style: tt.headlineMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              '¿Cómo podremos comunicarnos contigo?',
              style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              controller: phone,
              label: 'Teléfono',
              icon: Icons.phone,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            Consumer<PropertyViewModel>(
              builder: (context, propertyViewModel, child) {
                return DropdownButtonFormField<String>(
                  value: country,
                  decoration: const InputDecoration(
                    labelText: 'País',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  items: propertyViewModel.countries.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onCountryChanged,
                  validator: (v) => v == null ? 'Requerido' : null,
                );
              },
            ),
            const SizedBox(height: AppSpacing.m),
            Consumer<PropertyViewModel>(
              builder: (context, propertyViewModel, child) {
                final cities = country != null
                    ? propertyViewModel.getCitiesForCountry(country)
                    : <String>[];
                return DropdownButtonFormField<String>(
                  value: city,
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    prefixIcon: const Icon(Icons.location_city),
                    border: const OutlineInputBorder(),
                    // Si no hay país seleccionado, deshabilitamos el campo
                    enabled: country != null && cities.isNotEmpty,
                  ),
                  items: cities.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onCityChanged,
                  validator: (v) => v == null ? 'Requerido' : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
