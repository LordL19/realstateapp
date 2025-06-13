// lib/views/my_properties/my_properties_list_view.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/views/properties/property_detail_view.dart';
import 'package:realestate_app/widgets/my_properties/propery_card.dart';
import 'package:realestate_app/widgets/shared/property_filter_sheet.dart';
import 'package:realestate_app/widgets/shared/search_filter_bar.dart';
import '../../models/property.dart';
import '../../theme/theme.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../publish_property/publish_wizard.dart';

class MyPropertiesListView extends StatelessWidget {
  const MyPropertiesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = context.watch<PropertyViewModel>();

    final List<Property> filtered = vm.applyFilters(vm.myProperties);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Encabezado grande ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.l),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis propiedades',
                      style: Theme.of(context).textTheme.headlineLarge),
                  IconButton(
                    tooltip: 'Refrescar',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => vm.fetchMyProperties(),
                  ),
                ],
              ),
            ),

            // ---------- Barra de búsqueda / filtros ----------

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: SearchFilterBar(
                hasFilters: vm.hasActiveFilters,
                onTap: () async {
                  // Abrimos el modal **inyectando** el mismo ViewModel
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<PropertyViewModel>(),
                      child: const PropertyFilterSheet(),
                    ),
                  );
                  // Al cerrarse obligamos a redibujar
                  vm.refresh();
                },
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // ---------- Contenido ----------
            Expanded(
              child: Builder(
                builder: (_) {
                  switch (vm.myPropertiesState) {
                    case PropertyState.loading:
                      return const Center(child: CircularProgressIndicator());
                    case PropertyState.error:
                      return Center(
                        child: Text('Error: ${vm.errorMessage}'),
                      );
                    case PropertyState.loaded:
                      if (filtered.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.network(
                              'https://lottie.host/b0112925-f172-4c0c-be98-255b5ccc815b/76F3kTdmrM.json',
                              width: 240,
                              repeat: false,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text('Aún no has publicado propiedades',
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 290,
                          crossAxisSpacing: AppSpacing.m,
                          mainAxisSpacing: AppSpacing.m,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => PropertyCard(
                          property: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailView(
                                property: filtered[i],
                                isOwner: true,
                              ),
                            ),
                          ),
                        ),
                      );

                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),

      // ---------- FAB ----------
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_my_properties_list',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublishWizard()),
        ),
        backgroundColor: cs.primary,
        child: Icon(
          Icons.add,
          color: cs.onPrimary,
        ),
      ),
    );
  }
}
