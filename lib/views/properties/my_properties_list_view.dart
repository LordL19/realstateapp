import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/views/properties/property_visit_history_view.dart';
import 'package:realestate_app/views/publish_property/publish_wizard.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'property_form_view.dart';
import 'property_detail_view.dart';
import '../../widgets/property_filter_header.dart';

class MyPropertiesListView extends StatelessWidget {
  const MyPropertiesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Propiedades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<PropertyViewModel>().fetchMyProperties(),
          ),
        ],
      ),
      body: Consumer<PropertyViewModel>(
        builder: (context, viewModel, child) {
          final filteredProperties =
              viewModel.applyFilters(viewModel.myProperties);

          return Column(
            children: [
              const PropertyFilterHeader(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (viewModel.myPropertiesState) {
                      case PropertyState.loading:
                        return const Center(child: CircularProgressIndicator());
                      case PropertyState.error:
                        return Center(
                            child: Text('Error: ${viewModel.errorMessage}'));
                      case PropertyState.loaded:
                        if (filteredProperties.isEmpty) {
                          return const Center(
                            child: Text(
                                'No tienes propiedades que coincidan con los filtros.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: filteredProperties.length,
                          itemBuilder: (context, index) {
                            final property = filteredProperties[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailView(
                                        property: property,
                                        isOwner: true,
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: property.photos.isNotEmpty
                                      ? Image.network(property.photos.first,
                                          width: 80, fit: BoxFit.cover)
                                      : const Icon(Icons.house, size: 40),
                                  title: Text(property.title),
                                  subtitle: Text(
                                      '${property.city} - ${property.status}\n\$${property.price.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ChangeNotifierProvider.value(
                                                value: viewModel,
                                                child: PropertyFormView(
                                                    property: property),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      default:
                        return const Center(child: Text('Iniciando...'));
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_my_properties_list',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<PropertyViewModel>(),
                child: const PublishWizard(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, PropertyViewModel viewModel, String propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar esta propiedad? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await viewModel.deleteProperty(propertyId);
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
