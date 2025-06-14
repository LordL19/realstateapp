import 'package:flutter/material.dart';
import 'package:realestate_app/widgets/my_properties/propery_card.dart';
import '../../../models/property.dart';
import '../../../theme/theme.dart';

class RecentlyViewedStrip extends StatelessWidget {
  final List<Property> items;
  final ValueChanged<Property> onTap;

  const RecentlyViewedStrip({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (_, i) => SizedBox(
          width: 230,
          child: PropertyCard(
            property: items[i],
            onTap: () => onTap(items[i]),
          ),
        ),
      ),
    );
  }
}
