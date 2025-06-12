import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/visit_history_viewmodel.dart';
import '../../models/user_info_model.dart';

class PropertyVisitHistoryView extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const PropertyVisitHistoryView({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<PropertyVisitHistoryView> createState() => _PropertyVisitHistoryViewState();
}

class _PropertyVisitHistoryViewState extends State<PropertyVisitHistoryView> {
  final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<VisitHistoryViewModel>(context, listen: false)
          .fetchPropertyVisitHistory(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitHistoryViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Visitas - ${widget.propertyTitle}'),
      ),
      body: vm.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!))
              : vm.propertyVisitHistory.isEmpty
                  ? const Center(
                      child: Text('No hay historial de visitas disponible'),
                    )
                  : _buildVisitHistoryList(vm),
    );
  }

  Widget _buildVisitHistoryList(VisitHistoryViewModel vm) {
    // Group visits by date for better organization
    final Map<String, List<dynamic>> groupedVisits = {};
    
    for (var visit in vm.propertyVisitHistory) {
      final dateKey = DateFormat('yyyy-MM-dd').format(visit.visitDate);
      if (!groupedVisits.containsKey(dateKey)) {
        groupedVisits[dateKey] = [];
      }
      groupedVisits[dateKey]!.add(visit);
    }
    
    final sortedDates = groupedVisits.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final visitsOnDate = groupedVisits[dateKey]!;
        final displayDate = DateFormat('dd/MM/yyyy').format(
            DateTime.parse(dateKey));
            
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                displayDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...visitsOnDate.map((visit) {
              // Try different sources for visitor ID
              String visitorId = '';
              
              // Debug the visit data
              debugPrint("Visit ID: ${visit.id}, VisitorId: ${visit.visitorId}");
              
              // Try to get from explicit visitor ID field
              if (visit.visitorId != null && visit.visitorId!.isNotEmpty) {
                visitorId = visit.visitorId!;
                debugPrint("Using explicit visitor ID: $visitorId");
              }
              // Try to parse from visit.id
              else if (visit.id.contains('-')) {
                try {
                  final parts = visit.id.split('-');
                  if (parts.isNotEmpty) {
                    visitorId = parts[0];
                    debugPrint("Extracted ID from parts: $visitorId");
                  }
                } catch (e) {
                  debugPrint("Error splitting ID: $e");
                }
              } 
              // Fallback: use the full ID 
              else {
                visitorId = visit.id;
                debugPrint("Using full ID as fallback: $visitorId");
              }
              
              // Get user info if available
              UserInfo userInfo = vm.getUserInfo(visitorId);
              debugPrint("Got user info: ${userInfo.fullName}");
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      userInfo.firstName.isNotEmpty 
                        ? userInfo.firstName[0].toUpperCase() 
                        : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    userInfo.fullName.isNotEmpty 
                      ? userInfo.fullName 
                      : 'Usuario ${visitorId.substring(0, 6)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(visit.visitDate),
                      ),
                      if (userInfo.email.isNotEmpty)
                        Text(
                          userInfo.email,
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }
} 