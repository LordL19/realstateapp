import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/shared/app_date_field.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';

class ProfileSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name, last;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final DateTime? dob;
  final VoidCallback onPickDate;

  const ProfileSection({
    super.key,
    required this.formKey,
    required this.name,
    required this.last,
    required this.gender,
    required this.onGenderChanged,
    required this.dob,
    required this.onPickDate,
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
            Text('Perfil', style: tt.headlineMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Completa los datos personales.',
              style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              controller: name,
              label: 'Nombre',
              icon: Icons.person,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              controller: last,
              label: 'Apellido',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              children: ['M', 'F'].map((g) {
                final selected = g == gender;
                return ChoiceChip(
                  label: Text(g == 'M' ? 'Masculino' : 'Femenino'),
                  selected: selected,
                  onSelected: (_) => onGenderChanged(g),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppDateField(
              label: 'Fecha de nacimiento',
              date: dob,
              onTap: onPickDate,
              validator: (_) => dob == null ? 'Requerido' : null,
            ),
          ],
        ),
      ),
    );
  }
}
