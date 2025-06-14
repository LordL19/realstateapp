// lib/views/properties/property_detail_view.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/property.dart';
import '../../services/user_service.dart';
import '../../theme/theme.dart';
import '../../viewmodels/favorite_viewmodel.dart';
import '../../widgets/properties/hero_carousel.dart';
import '../../widgets/properties/quick_fact_chip.dart';
import '../../widgets/properties/static_map_preview.dart';
import 'package:realestate_app/views/publish_property/publish_wizard.dart';
import 'package:realestate_app/views/visits/visit_booking_view.dart';
import '../../viewmodels/visits_viewmodel.dart';
import '../../viewmodels/property_viewmodel.dart';

class PropertyDetailView extends StatefulWidget {
  final Property property;
  final bool isOwner;
  const PropertyDetailView({
    super.key,
    required this.property,
    required this.isOwner,
  });

  @override
  State<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  late Future<String> _listedBy;
  final _random = Random();
  static const LatLng _fallback = LatLng(-17.7833, -63.1821);

  @override
  void initState() {
    super.initState();
    final userSvc = context.read<UserService>();
    _listedBy = userSvc
        .getUserById(widget.property.idUser)
        .then((u) => u.email.trim())
        .catchError((_) => 'Propietario');

    final favVM = context.read<FavoriteViewModel>();
    if (favVM.state == FavoriteState.initial) favVM.fetchFavorites();
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'activa':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(locale: 'es_BO', symbol: '\$');
    final statusColor = _statusColor(p.status, context);
    final viewers = _random.nextInt(10) + 1; // 1–10 personas

    final LatLng coords = (p.latitude != null && p.longitude != null)
        ? LatLng(p.latitude!, p.longitude!)
        : _fallback;

    final desc = (p.description ?? '').trim().length < 50
        ? 'Esta propiedad ofrece un estilo de vida cómodo y contemporáneo, '
            'con espacios amplios y luminosos, acabados de primera calidad y una '
            'ubicación privilegiada cercana a centros comerciales, parques y '
            'servicios esenciales. Ideal para familias o profesionales que '
            'buscan confort y accesibilidad.'
        : p.description!.trim();

    return Consumer<FavoriteViewModel>(
      builder: (_, favVM, __) {
        final isFav = favVM.isFavorite(p.idProperty);

        return FutureBuilder<String>(
          future: _listedBy,
          builder: (_, snap) {
            final listedBy = snap.data ?? 'Publicado por…';

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  /* ---------- HERO ---------- */
                  HeroCarousel(
                    photos: p.photos,
                    listedBy: listedBy,
                    initiallyFav: isFav,
                    onBack: () => Navigator.pop(context),
                    onFavToggle: (v) => favVM.toggleFavorite(p.idProperty),
                  ),

                  /* ---------- CONTENIDO ---------- */
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl, AppSpacing.l, AppSpacing.xxl, 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status + Price + Address
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Text(
                                '${p.status[0].toUpperCase()}${p.status.substring(1)}',
                                style: tt.bodyLarge?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            currency.format(p.price),
                            style: GoogleFonts.golosText(
                              textStyle: tt.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text('Est. ${(p.price / 1716).round()} \$ / mes',
                              style: tt.bodyMedium),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            p.address ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.m),

                          // Nuevo texto de viewers
                          OutlinedButton(
                            onPressed: () {},
                            child: Text('$viewers personas viendo ahora mismo'),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Quick facts
                          Wrap(
                            spacing: AppSpacing.s,
                            runSpacing: AppSpacing.s,
                            children: [
                              QuickFactChip(
                                  icon: Icons.bed, label: '${p.bedrooms} hab.'),
                              QuickFactChip(
                                  icon: Icons.square_foot,
                                  label: '${p.builtArea} m² const.'),
                              QuickFactChip(
                                  icon: Icons.straighten,
                                  label: '${p.area} m² tot.'),
                              if (p.propertyType != null)
                                QuickFactChip(
                                    icon: Icons.home_work_outlined,
                                    label: p.propertyType!),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Divider(height: 1, thickness: .7, color: cs.outline),
                          const SizedBox(height: AppSpacing.l),

                          // Descripción
                          Text(desc, style: tt.bodyLarge),
                          const SizedBox(height: AppSpacing.xl),

                          // Mapa
                          StaticMapPreview(latLng: coords),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /* ---------- FOOTER ---------- */
              bottomNavigationBar: Material(
                color: cs.surface,
                elevation: 8,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Row(
                      children: [
                        // Solo "Agendar tour" para no-owners, editar para owners
                        Expanded(
                          child: widget.isOwner
                              ? OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChangeNotifierProvider.value(
                                          value:
                                              context.read<PropertyViewModel>(),
                                          child: PublishWizard(property: p),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Editar propiedad'),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                          create: (_) => VisitViewModel(),
                                          child: VisitBookingView(
                                            propertyId: p.idProperty,
                                            ownerId: p.idUser,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Agendar tour'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
