import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'property_form_view.dart';
import 'property_detail_view.dart';

class MyPropertiesListView extends StatelessWidget {
  const MyPropertiesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // El ViewModel se obtiene del provider que está en MainTabView
    final viewModel = Provider.of<PropertyViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Propiedades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchMyProperties(),
          ),
        ],
      ),
      body: Consumer<PropertyViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.myPropertiesState) {
            case PropertyState.loading:
              return const Center(child: CircularProgressIndicator());
            case PropertyState.error:
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            case PropertyState.loaded:
              if (viewModel.myProperties.isEmpty) {
                return const Center(
                    child: Text('Aún no has creado ninguna propiedad.'));
              }
              return ListView.builder(
                itemCount: viewModel.myProperties.length,
                itemBuilder: (context, index) {
                  final property = viewModel.myProperties[index];
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: viewModel,
                                      child:
                                          PropertyFormView(property: property),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(
                                  context, viewModel, property.idProperty),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_my_properties_list',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: viewModel,
                child: const PropertyFormView(),
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
