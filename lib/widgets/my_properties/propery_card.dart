import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:realestate_app/models/property.dart';
import 'package:realestate_app/theme/theme.dart';

/// Indicador para marcar la tarjeta: favorito o visto
enum CardMarker { none, favourite, viewed }

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final CardMarker marker; // ❤ favorito o 👁 visto
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.marker = CardMarker.none,
    this.onEdit,
    this.onDelete,
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
    final priceFmt = NumberFormat.currency(
      locale: 'es_BO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto, estado y menú
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: property.photos.isNotEmpty
                        ? Image.network(property.photos.first,
                            fit: BoxFit.cover)
                        : const ColoredBox(
                            color: Colors.black12,
                            child: Center(
                              child: Icon(Icons.house_outlined,
                                  size: 48, color: Colors.white70),
                            ),
                          ),
                  ),
                ),

                // Badge de status
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(property.status, cs).withOpacity(.9),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      property.status,
                      style: tt.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),

                // Menú contextual editar/eliminar (si aplica)
                if (onEdit != null || onDelete != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: PopupMenuButton<int>(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      icon: Icon(Icons.more_vert, color: cs.onSurface),
                      onSelected: (value) {
                        if (value == 0) onEdit?.call();
                        if (value == 1) onDelete?.call();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 0,
                          child: Row(children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar')
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 1,
                          child: Row(children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text('Eliminar')
                          ]),
                        ),
                      ],
                    ),
                  ),

                // Indicador favorito o visto
                if (marker != CardMarker.none)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        marker == CardMarker.favourite
                            ? Icons.favorite
                            : Icons.visibility,
                        size: 20,
                        color: marker == CardMarker.favourite
                            ? Colors.redAccent
                            : cs.primary,
                      ),
                    ),
                  ),
              ],
            ),

            // Detalles de texto
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceFmt.format(property.price),
                    style: GoogleFonts.golosText(
                      textStyle: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.propertyType ?? ''} · ${property.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.address ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (property.description != null &&
                      property.description!.trim().isNotEmpty)
                    Text(
                      property.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall,
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Métricas
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
              child: Wrap(
                spacing: AppSpacing.s,
                children: [
                  _metricChip(
                      Icons.square_foot, '${property.builtArea} m²', cs),
                  _metricChip(Icons.bed, '${property.bedrooms}', cs),
                ],
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
