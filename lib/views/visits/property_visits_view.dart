import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../../viewmodels/visits_viewmodel.dart';
import '../properties/property_detail_view.dart';

class PropertyVisitsView extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const PropertyVisitsView({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<PropertyVisitsView> createState() => _PropertyVisitsViewState();
}

class _PropertyVisitsViewState extends State<PropertyVisitsView> {
  String selectedStatus = 'todas';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<VisitViewModel>(context, listen: false)
          .fetchPropertyVisits(widget.propertyId);
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties();
    });
  }

  Future<void> _changeStatus(String visitId, String newStatus) async {
    final vm = context.read<VisitViewModel>();
    final success = await vm.updateVisitStatus(visitId, newStatus);
    if (success) {
      await vm.fetchPropertyVisits(widget.propertyId);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitViewModel>();
    final propVM = context.watch<PropertyViewModel>();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    final visits = vm.propertyVisits
        .where((v) => selectedStatus == 'todas' || v.status == selectedStatus)
        .toList()
      ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));

    return Scaffold(
      appBar: AppBar(
        title: Text("Tours de ${widget.propertyTitle}"),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              icon: const Icon(Icons.filter_list),
              onChanged: (value) => setState(() => selectedStatus = value!),
              items: const [
                DropdownMenuItem(value: 'todas', child: Text('Todas')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'aceptada', child: Text('Aceptada')),
                DropdownMenuItem(value: 'rechazada', child: Text('Rechazada')),
                DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : visits.isEmpty
              ? const Center(child: Text("No hay tours con ese estado."))
              : RefreshIndicator(
                  onRefresh: () => vm.fetchPropertyVisits(widget.propertyId),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final visit = visits[index];
                      final property = propVM.getPropertyById(visit.propertyId);

                      return GestureDetector(
                        onTap: () {
                          if (property != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailView(
                                  property: property,
                                  isOwner: true,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white60,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SizedBox(
                            height: 190,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                  child: property?.photos.isNotEmpty == true
                                      ? Image.network(
                                          property!.photos.first,
                                          width: 120,
                                          height: 190,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 120,
                                          height: 190,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          property?.title ?? 'Propiedad',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${property?.propertyType ?? ''} · ${property?.city ?? ''}',
                                          style: TextStyle(
                                              color: Colors.grey.shade700),
                                        ),
                                        Text(
                                          property?.address ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Fecha: ${dateFormat.format(visit.requestedDateTime)}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Contacto: ${visit.contactPhone}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          visit.contactEmail,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          visit.status.toUpperCase(),
                                          style: TextStyle(
                                            color: _statusColor(visit.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (visit.status != "rechazada")
                                  PopupMenuButton<String>(
                                    onSelected: (v) =>
                                        _changeStatus(visit.id, v),
                                    itemBuilder: (_) => [
                                      if (visit.status == "pendiente")
                                        const PopupMenuItem(
                                          value: 'aceptada',
                                          child: Text('Aceptar'),
                                        ),
                                      if (visit.status == "pendiente")
                                        const PopupMenuItem(
                                          value: 'rechazada',
                                          child: Text('Rechazar'),
                                        ),
                                      if (visit.status == "aceptada")
                                        const PopupMenuItem(
                                          value: 'cancelada',
                                          child: Text('Cancelar'),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
