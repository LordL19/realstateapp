import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:realestate_app/models/property.dart';
import 'package:realestate_app/viewmodels/property_viewmodel.dart';
import 'package:realestate_app/views/properties/property_detail_view.dart';
import '../../viewmodels/visit_history_viewmodel.dart';

class UserVisitHistoryView extends StatefulWidget {
  const UserVisitHistoryView({super.key});

  @override
  State<UserVisitHistoryView> createState() => _UserVisitHistoryViewState();
}

class _UserVisitHistoryViewState extends State<UserVisitHistoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final propertyVM = Provider.of<PropertyViewModel>(context, listen: false);
      // Cargar siempre lista de propiedades públicas y las del usuario
      propertyVM.fetchProperties();
      propertyVM.fetchMyProperties();
      Provider.of<VisitHistoryViewModel>(context, listen: false)
          .fetchUserVisitHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Visitas'),
      ),
      body: Consumer2<VisitHistoryViewModel, PropertyViewModel>(
        builder: (context, visitHistoryVM, propertyVM, child) {
          if (visitHistoryVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (visitHistoryVM.errorMessage != null) {
            return Center(child: Text(visitHistoryVM.errorMessage!));
          }
          
          if (visitHistoryVM.userVisitHistory.isEmpty) {
            return const Center(
              child: Text('No has visitado ninguna propiedad todavía.'),
            );
          }

          // Get current user info for debugging
          final currentUser = visitHistoryVM.currentUser;
          debugPrint("Current user in view: ${currentUser?.id ?? 'No user found'}");
          
          // Log visit history items
          for (var visit in visitHistoryVM.userVisitHistory) {
            debugPrint("Visit property: ${visit.idProperty}, owner: ${visit.ownerId ?? 'unknown'}");
          }

          // Obtener IDs de propiedades propias
          final ownPropertyIds = propertyVM.myProperties.map((p)=>p.idProperty).toSet();

          // Filtrar historial quitando propiedades propias por ID
          final filteredHistory = visitHistoryVM.userVisitHistory.where((visit) => !ownPropertyIds.contains(visit.idProperty)).toList();
          
          debugPrint("After own ID filter: ${filteredHistory.length} of ${visitHistoryVM.userVisitHistory.length}");
          
          if(filteredHistory.isEmpty){
            return const Center(child: Text('No has visitado propiedades de otros usuarios todavía.'));
          }
          
          final visitedPropertyIds = filteredHistory.map((v)=>v.idProperty).toSet().toList();

          // Filter the main property list
          List<dynamic> visitedItems = [];
          
          // If properties are loaded, use them
          if (propertyVM.properties.isNotEmpty) {
            // Get matching properties
            final matchingProperties = propertyVM.properties
                .where((p) => visitedPropertyIds.contains(p.idProperty))
                .toList();
            
            visitedItems = matchingProperties;
          }
          
          // If no properties matched or they're still loading, use visit history
          if (visitedItems.isEmpty) {
            // Fall back to using just the visit history info
            visitedItems = filteredHistory;
          }

          if (visitedItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando propiedades visitadas...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await visitHistoryVM.fetchUserVisitHistory();
              await propertyVM.fetchProperties();
            },
            child: ListView.builder(
              itemCount: visitedItems.length,
              itemBuilder: (context, index) {
                final item = visitedItems[index];
                
                if (item is Property) {
                  return _buildPropertyCard(context, item);
                } else {
                  // It's a VisitHistory item
                  return _buildHistoryCard(context, item);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PropertyDetailView(
                property: property,
                isOwner: false, // Assuming user is not the owner when viewing from history
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: property.photos.isNotEmpty
                  ? Image.network(
                      property.photos.first,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 180, color: Colors.grey[200]),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.house_outlined,
                          size: 60, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.propertyType} en ${property.transactionType}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property.city}, ${property.country}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(property.price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
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

  // Simplified card for when Property data is not available
  Widget _buildHistoryCard(BuildContext context, dynamic visit) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              visit.propertyTitle ?? 'Sin título',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('Tipo: ${visit.propertyType}'),
            Text('Transacción: ${visit.transactionType}'),
            Text('Ubicación: ${visit.city}, ${visit.country}'),
            const SizedBox(height: 8),
            Text(
              'Última visita: ${DateFormat('dd/MM/yyyy – HH:mm').format(visit.visitDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
} 