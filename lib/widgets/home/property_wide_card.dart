// lib/widgets/properties/property_wide_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/property.dart';
import '../../theme/theme.dart';

class PropertyWideCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyWideCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  Color _statusColor(String status, ColorScheme cs) {
    switch (status.toLowerCase()) {
      case 'vendido':
      case 'reservado':
        return cs.outline;
      case 'alquiler':
      case 'for rent':
        return cs.primary;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final price = NumberFormat.currency(
      locale: 'es_BO',
      symbol: '\$',
      decimalDigits: 0,
    ).format(property.price);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        height: 220,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            /* ──────────── FOTO ──────────── */
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24)),
                    child: SizedBox.expand(
                      child: property.photos.isNotEmpty
                          ? Image.network(
                              property.photos.first,
                              fit: BoxFit.cover,
                            )
                          : const ColoredBox(color: Colors.black12),
                    ),
                  ),

                  // Estado (badge)
                  Positioned(
                    top: AppSpacing.m,
                    right: AppSpacing.m,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(property.status, cs)
                            .withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(property.status,
                          style: tt.labelMedium?.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            /* ──────────── INFO ──────────── */
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.m, horizontal: AppSpacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Precio
                    Text(
                      price,
                      style: GoogleFonts.golosText(
                        textStyle: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700, color: cs.primary),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Título (tipo + ciudad)
                    Text(
                      '${property.propertyType} · ${property.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),

                    // Dirección
                    if (property.address != null)
                      Text(
                        property.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant, height: 1.2),
                      ),

                    // Descripción
                    if (property.description != null &&
                        property.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.s * .75),
                        child: Text(
                          property.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),

                    const Spacer(),

                    // Métricas
                    Row(
                      children: [
                        _metricChip(
                            Icons.square_foot, '${property.builtArea} m²', cs),
                        const SizedBox(width: AppSpacing.s),
                        _metricChip(Icons.bed, '${property.bedrooms}', cs),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(IconData icon, String label, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface)),
        ],
      ),
    );
  }
}
