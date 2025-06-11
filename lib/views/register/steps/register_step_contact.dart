import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';

class ContactSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phone, city, country;

  const ContactSection({
    super.key,
    required this.formKey,
    required this.phone,
    required this.city,
    required this.country,
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
            AppTextField(
              controller: city,
              label: 'Ciudad',
              icon: Icons.location_city,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              controller: country,
              label: 'País',
              icon: Icons.flag,
            ),
          ],
        ),
      ),
    );
  }
}
