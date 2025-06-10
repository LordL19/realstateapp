import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'property_form_view.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/property.dart';
import 'property_detail_view.dart';

class PropertyListView extends StatelessWidget {
  const PropertyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Propiedades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PropertyViewModel>().fetchProperties(),
          ),
        ],
      ),
      body: Consumer<PropertyViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case PropertyState.loading:
              return const Center(child: CircularProgressIndicator());
            case PropertyState.error:
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            case PropertyState.loaded:
              if (viewModel.publicProperties.isEmpty) {
                return const Center(child: Text('No hay propiedades disponibles.'));
              }
              return ListView.builder(
                itemCount: viewModel.publicProperties.length,
                itemBuilder: (context, index) {
                  final property = viewModel.publicProperties[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailView(property: property),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPropertyImage(property),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _buildPropertyInfo(property),
                          ),
                        ],
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
    );
  }

  Widget _buildPropertyImage(Property property) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: property.photos.isNotEmpty
          ? Image.network(
              property.photos.first,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null ? child : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
              },
            )
          : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.house, size: 80, color: Colors.grey),
            ),
    );
  }

  Widget _buildPropertyInfo(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${property.city}, ${property.country}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${property.price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
} 