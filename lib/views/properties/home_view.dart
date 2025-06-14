// lib/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/widgets/home/featured_carousel.dart';
import 'package:realestate_app/widgets/home/recently_viewed_strip.dart';
import 'package:realestate_app/widgets/home/recommendation_grid.dart';

import '../../models/property.dart';
import '../../theme/theme.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../../viewmodels/visit_history_viewmodel.dart';
import '../properties/property_detail_view.dart';

import '../../widgets/home/home_header.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/property_filter_sheet.dart';
import '../../widgets/my_properties/propery_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = context.watch<PropertyViewModel>();
    final vhVm = context.watch<VisitHistoryViewModel>();

    final visitedIds = vhVm.userVisitHistory.map((v) => v.idProperty).toSet();
    final recently =
        vm.properties.where((p) => visitedIds.contains(p.idProperty)).toList();

    /* ───────────────────────── GRID + EMPTY STATE ─────────────────────── */
    if (vm.hasActiveFilters) {
      final filtered = vm.applyFilters(vm.publicProperties);

      return Scaffold(
        body: CustomScrollView(
          controller: _scroll,
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xl),
                child: SearchFilterBar(
                  hasFilters: vm.hasActiveFilters,
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vm,
                        child: const PropertyFilterSheet(),
                      ),
                    );
                    vm.refresh();
                  },
                ),
              ),
            ),

            // Mensaje si vacío
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.network(
                        'https://assets2.lottiefiles.com/packages/lf20_HpFqiS.json',
                        width: 220,
                        repeat: false,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'No encontramos propiedades\nque coincidan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 4 × 4
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    mainAxisExtent: 320,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => PropertyCard(
                      property: filtered[i],
                      onTap: () => _openProperty(filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      );
    }

    /* ─────────────────────── SIN FILTROS → flujo original ────────────── */
    return Scaffold(
      body: ListView(
        controller: _scroll,
        padding: EdgeInsets.zero,
        children: [
          const HomeHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xl),
            child: SearchFilterBar(
              hasFilters: vm.hasActiveFilters,
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const PropertyFilterSheet(),
                  ),
                );
                vm.refresh();
              },
            ),
          ),

/* ---------- FEATURED CAROUSEL ---------- */
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.l),
            child: FeaturedCarousel(
              items: vm.featuredProperties,
              onTap: _openProperty,
            ),
          ),

/* ---------- RECENTLY VIEWED ---------- */
          if (recently.isNotEmpty) ...[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, 0, AppSpacing.m),
              child: Text(
                'Recently viewed',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            RecentlyViewedStrip(
              items: recently,
              onTap: _openProperty,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

/* ---------- RECOMMENDATIONS ---------- */
          Padding(
            padding:
                const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, 0, AppSpacing.m),
            child: Text(
              'Podría interesarte',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          RecommendationGrid(
            items: vm.recommendations,
            onTap: _openProperty,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _openProperty(Property p) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyDetailView(property: p, isOwner: false),
        ),
      );
}
