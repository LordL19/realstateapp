import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class ActionTilesSection extends StatelessWidget {
  final VoidCallback onOwnerVisits;
  const ActionTilesSection({super.key, required this.onOwnerVisits});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Más acciones',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.m),
        Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          color: cs.surfaceContainerHighest,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Visitas solicitadas a mis inmuebles'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: onOwnerVisits,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Cambiar contraseña'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {}, // TODO
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ajustes de la app'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {}, // TODO
              ),
            ],
          ),
        ),
      ],
    );
  }
}
