// lib/views/property_detail/widgets/quick_fact_chip.dart
import 'package:flutter/material.dart';

class QuickFactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const QuickFactChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 16, color: cs.onPrimary),
      label: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: cs.onPrimary)),
      backgroundColor: cs.primary,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
