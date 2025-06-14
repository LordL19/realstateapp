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
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 360;
    final cols = narrow ? 1 : 2;
    final double extent = narrow ? 340 : 320;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisExtent: extent,
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
