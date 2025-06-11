import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'property_form_view.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/property.dart';
import 'property_detail_view.dart';
import '../../viewmodels/favorite_viewmodel.dart';
import '../../widgets/property_filter_header.dart';

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
            onPressed: () {
              context.read<PropertyViewModel>().fetchProperties();
              context.read<FavoriteViewModel>().fetchFavorites();
            },
          ),
        ],
      ),
      body: Consumer<PropertyViewModel>(
        builder: (context, viewModel, child) {
          final filteredProperties =
              viewModel.applyFilters(viewModel.publicProperties);

          return Column(
            children: [
              const PropertyFilterHeader(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (viewModel.state) {
                      case PropertyState.loading:
                        return const Center(child: CircularProgressIndicator());
                      case PropertyState.error:
                        return Center(
                            child: Text('Error: ${viewModel.errorMessage}'));
                      case PropertyState.loaded:
                        if (filteredProperties.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No hay propiedades que coincidan con los filtros.'));
                        }
                        return ListView.builder(
                          itemCount: filteredProperties.length,
                          itemBuilder: (context, index) {
                            final property = filteredProperties[index];
                            return Consumer<FavoriteViewModel>(
                              builder: (context, favoriteVM, child) {
                                final isFavorite =
                                    favoriteVM.isFavorite(property.idProperty);
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PropertyDetailView(
                                            property: property,
                                            isOwner: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPropertyImageWithFavorite(
                                            property,
                                            isFavorite,
                                            () => favoriteVM.toggleFavorite(
                                                property.idProperty)),
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
    );
  }

  Widget _buildPropertyImageWithFavorite(
      Property property, bool isFavorite, VoidCallback onToggle) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: property.photos.isNotEmpty
              ? Image.network(
                  property.photos.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 40, color: Colors.grey);
                  },
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.house, size: 80, color: Colors.grey),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onToggle,
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
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
