import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class QuickStatsRow extends StatelessWidget {
  final int favourites;
  final int myProperties;
  final int visits;
  final VoidCallback onTapFav;
  final VoidCallback onTapProps;
  final VoidCallback onTapVisits;
  const QuickStatsRow({
    super.key,
    required this.favourites,
    required this.myProperties,
    required this.visits,
    required this.onTapFav,
    required this.onTapProps,
    required this.onTapVisits,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.l,
      runSpacing: AppSpacing.l,
      children: [
        _statChip(context,
            icon: Icons.favorite,
            count: favourites,
            label: 'Favoritos',
            onTap: onTapFav),
        _statChip(context,
            icon: Icons.home_work_outlined,
            count: myProperties,
            label: 'Mis propiedades',
            onTap: onTapProps),
        _statChip(context,
            icon: Icons.visibility,
            count: visits,
            label: 'Visitas',
            onTap: onTapVisits),
      ],
    );
  }

  Widget _statChip(BuildContext context,
      {required IconData icon,
      required int count,
      required String label,
      required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l, vertical: AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(height: AppSpacing.xs),
              Text('$count',
                  style: tt.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1)),
              Text(label,
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
