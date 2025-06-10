import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'create_property_view.dart';

class PropertyListView extends StatelessWidget {
  const PropertyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos el cliente de GraphQL aquí, fuera del callback 'create'.
    final client = GraphQLProvider.of(context).value;

    return ChangeNotifierProvider(
      // Ahora usamos la variable 'client' que capturamos antes.
      create: (context) => PropertyViewModel(client: client)..fetchProperties(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catálogo de Propiedades'),
        ),
        body: const PropertyList(),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      // Compartimos el mismo ViewModel para no tener que recargar la lista
                      ChangeNotifierProvider.value(
                    value: context.read<PropertyViewModel>(),
                    child: const CreatePropertyView(),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class PropertyList extends StatelessWidget {
  const PropertyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.state) {
          case PropertyState.loading:
            return const Center(child: CircularProgressIndicator());
          case PropertyState.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.errorMessage}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchProperties(),
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          case PropertyState.loaded:
            if (viewModel.properties.isEmpty) {
              return const Center(
                child: Text('No hay propiedades disponibles.'),
              );
            }
            return ListView.builder(
              itemCount: viewModel.properties.length,
              itemBuilder: (context, index) {
                final property = viewModel.properties[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: property.photos.isNotEmpty
                        ? Image.network(
                            property.photos.first,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.house, size: 50),
                          )
                        : const Icon(Icons.house, size: 50),
                    title: Text(property.title),
                    subtitle: Text(
                      '${property.city}, ${property.country}\n\$${property.price.toStringAsFixed(2)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          case PropertyState.initial:
          default:
            return const Center(child: Text('Iniciando...'));
        }
      },
    );
  }
} 