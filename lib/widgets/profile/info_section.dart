// lib/views/profile/widgets/info_section.dart
import 'package:flutter/material.dart';
import 'package:realestate_app/models/user_profile.dart';
import '../../../theme/theme.dart';

class PersonalInfoSection extends StatelessWidget {
  final UserProfile profile;
  const PersonalInfoSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget row(IconData ic, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            children: [
              Icon(ic, color: cs.primary),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: tt.labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(value.isEmpty ? '—' : value,
                        style: tt.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información personal',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.l),

            // ---- campos ----
            row(Icons.person, 'Nombre completo',
                '${profile.firstName} ${profile.lastName}'),
            row(Icons.email, 'Email', profile.email),
            row(Icons.flag, 'País', profile.country),
            row(Icons.location_city, 'Ciudad', profile.city),
          ],
        ),
      ),
    );
  }
}
