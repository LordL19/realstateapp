import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/models/create_visit_history_request.dart';
import 'package:realestate_app/viewmodels/visit_history_viewmodel.dart';
import 'package:realestate_app/views/properties/property_visit_history_view.dart';
import 'package:realestate_app/views/visits/property_visits_view.dart';
import 'package:realestate_app/views/visits/visit_booking_view.dart';
import '../../models/property.dart';
import 'package:intl/intl.dart';

class PropertyDetailView extends StatefulWidget {
  final Property property;
  final bool isOwner;

  const PropertyDetailView(
      {super.key, required this.property, required this.isOwner});

  @override
  State<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  @override
  void initState() {
    super.initState();
    // Record visit to property when details are viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visitHistoryVM = Provider.of<VisitHistoryViewModel>(context, listen: false);
      final request = CreateVisitHistoryRequest(
        idProperty: widget.property.idProperty,
        propertyTitle: widget.property.title,
        propertyType: widget.property.propertyType ?? 'No especificado',
        transactionType: widget.property.transactionType ?? 'No especificado',
        city: widget.property.city,
        country: widget.property.country,
        ownerId: widget.property.idUser,
      );
      visitHistoryVM.recordVisit(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final areaFormat = NumberFormat.decimalPattern('es_CO');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.title),
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
                    widget.property.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.property.transactionType} - ${widget.property.propertyType}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(widget.property.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, Icons.location_on,
                      '${widget.property.address}, ${widget.property.city}, ${widget.property.country}'),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property.description ?? 'No hay descripción disponible.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Características',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureChip('Habitaciones',
                      widget.property.bedrooms.toString(), Icons.king_bed),
                  _buildFeatureChip(
                      'Área total',
                      '${areaFormat.format(widget.property.area)} m²',
                      Icons.straighten),
                  _buildFeatureChip(
                      'Área construida',
                      '${areaFormat.format(widget.property.builtArea)} m²',
                      Icons.crop_square),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, Icons.info_outline,
                      'Estado: ${widget.property.status}'),
                  if (widget.isOwner) ...[
                    ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text("Visitas agendadas"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PropertyVisitsView(
                                    propertyId: widget.property.idProperty,
                                    propertyTitle: widget.property.title,
                                  )),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text("Historial de visitas"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PropertyVisitHistoryView(
                                    propertyId: widget.property.idProperty,
                                    propertyTitle: widget.property.title,
                                  )),
                        );
                      },
                    ),
                  ],
                  if (!widget.isOwner)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitBookingView(
                              propertyId: widget.property.idProperty,
                              ownerId: widget.property.idUser,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Agendar visita'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.property.photos.isEmpty) {
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
      items: widget.property.photos
          .map((item) => Container(
                child: Center(
                    child: Image.network(item,
                        fit: BoxFit.cover, width: double.infinity)),
              ))
          .toList(),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
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
