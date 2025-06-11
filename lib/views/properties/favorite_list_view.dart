import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property.dart';
import '../../viewmodels/favorite_viewmodel.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'property_detail_view.dart';

class FavoriteListView extends StatelessWidget {
  const FavoriteListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteVM = Provider.of<FavoriteViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => favoriteVM.fetchFavorites(),
          ),
        ],
      ),
      body: Consumer2<PropertyViewModel, FavoriteViewModel>(
        builder: (context, propertyVM, favoriteVM, child) {
          if (favoriteVM.state == FavoriteState.loading ||
              propertyVM.state == PropertyState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favoriteVM.state == FavoriteState.error) {
            return Center(child: Text('Error: ${favoriteVM.errorMessage}'));
          }

          final List<Property> favoriteProperties = propertyVM.properties
              .where((p) => favoriteVM.favoriteIds.contains(p.idProperty))
              .toList();

          if (favoriteProperties.isEmpty) {
            return const Center(child: Text('No tienes propiedades favoritas.'));
          }

          return ListView.builder(
            itemCount: favoriteProperties.length,
            itemBuilder: (context, index) {
              final property = favoriteProperties[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                      _buildPropertyImage(context, property),
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
      ),
    );
  }

  Widget _buildPropertyImage(BuildContext context, Property property) {
    final favoriteVM = Provider.of<FavoriteViewModel>(context, listen: false);
    final isFavorite = favoriteVM.isFavorite(property.idProperty);
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
                  child:
                      const Icon(Icons.house, size: 80, color: Colors.grey),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => favoriteVM.toggleFavorite(property.idProperty),
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