import 'package:flutter/material.dart';
import 'package:realestate_app/widgets/my_properties/propery_card.dart';
import '../../../models/property.dart';
import '../../../theme/theme.dart';

class RecommendationGrid extends StatelessWidget {
  final List<Property> items;
  final ValueChanged<Property> onTap;

  const RecommendationGrid({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 320,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => PropertyCard(
        property: items[i],
        onTap: () => onTap(items[i]),
      ),
    );
  }
}
