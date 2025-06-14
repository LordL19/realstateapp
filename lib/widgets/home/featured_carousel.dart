import 'package:flutter/material.dart';
import 'package:realestate_app/widgets/home/property_wide_card.dart';
import '../../../models/property.dart';
import '../../../theme/theme.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<Property> items;
  final ValueChanged<Property> onTap;

  const FeaturedCarousel({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: PageController(viewportFraction: .9),
        itemCount: items.length,
        padEnds: false,
        itemBuilder: (_, i) {
          final p = items[i];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.l),
            child: PropertyWideCard(
              property: p,
              onTap: () => onTap(p),
            ),
          );
        },
      ),
    );
  }
}
