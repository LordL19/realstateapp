// lib/views/fav_history/fav_history_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/widgets/my_properties/propery_card.dart';
import '../../models/property.dart';
import '../../viewmodels/favorite_viewmodel.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../../viewmodels/visit_history_viewmodel.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/property_filter_sheet.dart';
import '../properties/property_detail_view.dart';
import '../../theme/theme.dart';

class FavHistoryView extends StatefulWidget {
  const FavHistoryView({super.key});

  @override
  State<FavHistoryView> createState() => _FavHistoryViewState();
}

class _FavHistoryViewState extends State<FavHistoryView> {
  int _segment = 0; // 0 → favoritos, 1 → historial

  @override
  void initState() {
    super.initState();
    // cargar datos necesarios
    Future.microtask(() {
      context.read<FavoriteViewModel>().fetchFavorites();
      context.read<PropertyViewModel>().fetchProperties();
      context.read<VisitHistoryViewModel>().fetchUserVisitHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = context.watch<PropertyViewModel>();
    final favVm = context.watch<FavoriteViewModel>();
    final vhVm = context.watch<VisitHistoryViewModel>();

    // Construir listas base con IDs para evitar problemas de sincronización
    final Set<String> favoriteIds = favVm.favoriteIds;
    final Set<String> historyIds = vhVm.userVisitHistory
        .map((v) => v.idProperty)
        .toSet();
        
    // Filtrar propiedades según la pestaña activa
    final baseList = vm.properties.where((p) => 
        _segment == 0 
            ? favoriteIds.contains(p.idProperty) 
            : historyIds.contains(p.idProperty)
    ).toList();
    
    // Aplicar filtros adicionales
    final list = vm.hasActiveFilters ? vm.applyFilters(baseList) : baseList;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- TÍTULO ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mi actividad',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  IconButton(
                    tooltip: 'Refrescar',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      favVm.fetchFavorites();
                      vhVm.fetchUserVisitHistory();
                      vm.fetchProperties();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // ---------- SEARCH & FILTER BAR ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: SearchFilterBar(
                hasFilters: vm.hasActiveFilters,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const PropertyFilterSheet(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            // ---------- SEGMENTED CONTROL ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                      value: 0,
                      icon: Icon(Icons.favorite),
                      label: Text('Favoritos')),
                  ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.visibility),
                      label: Text('Historial')),
                ],
                selected: {_segment},
                onSelectionChanged: (s) {
                  setState(() => _segment = s.first);
                  // Asegurar que los datos estén actualizados al cambiar de pestaña
                  if (_segment == 0) {
                    favVm.fetchFavorites();
                  } else {
                    vhVm.fetchUserVisitHistory();
                  }
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16)),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // ---------- CONTENIDO ----------
            Expanded(child: _buildBody(cs, list)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, List<Property> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          _segment == 0 ? 'Sin favoritos' : 'Aún no has visto propiedades',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return GridView.builder(
      key: ValueKey('fav_history_grid_${_segment}'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 320,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final prop = list[i];
        return PropertyCard(
          key: ValueKey(prop.idProperty),
          property: prop,
          marker: _segment == 0 ? CardMarker.favourite : CardMarker.viewed,
          onTap: () async {
            // Navegar a la vista de detalle
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailView(property: prop, isOwner: false),
              ),
            );
            
            // Recargar datos al volver para asegurar sincronización
            if (_segment == 0) {
              context.read<FavoriteViewModel>().fetchFavorites();
            } else {
              context.read<VisitHistoryViewModel>().fetchUserVisitHistory();
            }
          },
        );
      },
    );
  }
}
