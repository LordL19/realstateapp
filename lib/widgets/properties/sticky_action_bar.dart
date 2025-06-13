// lib/views/properties/widgets/sticky_action_bar.dart
import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class StickyActionBar extends StatelessWidget {
  final VoidCallback? onScheduleTour;
  final VoidCallback onContactAgent;
  final bool isOwner;
  const StickyActionBar({
    super.key,
    required this.onScheduleTour,
    required this.onContactAgent,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: isOwner ? null : onScheduleTour,
                child: const Text('Schedule tour'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: OutlinedButton(
                onPressed: onContactAgent,
                child: Text(isOwner ? 'View visits' : 'Contact an agent'),
              ),
            ),
          ],
        ),
      );
}
