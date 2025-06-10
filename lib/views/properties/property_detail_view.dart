import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/property.dart';
import 'package:intl/intl.dart';


class PropertyDetailView extends StatelessWidget {
  final Property property;

  const PropertyDetailView({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final areaFormat = NumberFormat.decimalPattern('es_CO');

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildImageCarousel(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property.transactionType} - ${property.propertyType}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(property.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, Icons.location_on, '${property.address}, ${property.city}, ${property.country}'),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description ?? 'No hay descripción disponible.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Características',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureChip('Habitaciones', property.bedrooms.toString(), Icons.king_bed),
                  _buildFeatureChip('Área total', '${areaFormat.format(property.area)} m²', Icons.straighten),
                  _buildFeatureChip('Área construida', '${areaFormat.format(property.builtArea)} m²', Icons.crop_square),
                   const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, Icons.info_outline, 'Estado: ${property.status}'),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (property.photos.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.house_outlined, size: 100, color: Colors.grey),
        ),
      );
    }
    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
      ),
      items: property.photos.map((item) => Container(
        child: Center(
          child: Image.network(item, fit: BoxFit.cover, width: double.infinity)
        ),
      )).toList(),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
      ],
    );
  }
   Widget _buildFeatureChip(String label, String value, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
} 