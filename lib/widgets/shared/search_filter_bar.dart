// lib/views/my_properties/widgets/search_filter_bar.dart
import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class SearchFilterBar extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onTap;
  const SearchFilterBar({
    super.key,
    required this.hasFilters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: cs.onSurfaceVariant),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                hasFilters ? 'Filtros activos' : 'Buscar o filtrar',
                style: tt.bodyMedium?.copyWith(
                  color: hasFilters ? cs.onSurface : cs.onSurfaceVariant,
                  fontWeight: hasFilters ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (hasFilters)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
