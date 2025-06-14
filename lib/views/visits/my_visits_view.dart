import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:realestate_app/viewmodels/property_viewmodel.dart';
import 'package:realestate_app/views/properties/property_detail_view.dart';
import '../../viewmodels/visits_viewmodel.dart';

class MyVisitsView extends StatefulWidget {
  const MyVisitsView({super.key});

  @override
  State<MyVisitsView> createState() => _MyVisitsViewState();
}

class _MyVisitsViewState extends State<MyVisitsView> {
  String selectedStatus = 'todas';

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<VisitViewModel>(context, listen: false);
    final propertyVM = Provider.of<PropertyViewModel>(context, listen: false);

    vm.fetchMyVisits();
    propertyVM.fetchProperties();
  }

  Future<void> _confirmCancel(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancelar Visita"),
        content: const Text("¿Estás seguro de cancelar esta visita?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Sí, cancelar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<VisitViewModel>();
      await vm.fetchMyVisits();
    }
  }

  Color _buildStatusChip(String status) {
    Color sColor;
    switch (status) {
      case 'aceptada':
        sColor = Colors.green;
        break;
      case 'rechazada':
      case 'cancelada':
        sColor = Colors.red;
        break;
      case 'pendiente':
        sColor = Colors.orange;
        break;
      default:
        sColor = Colors.grey;
    }

    return sColor;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    final visits = vm.myVisits
        .where((visit) =>
            selectedStatus == 'todas' || visit.status == selectedStatus)
        .toList()
      ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Visitas"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                icon: const Icon(Icons.filter_list),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'todas', child: Text('Todas')),
                  DropdownMenuItem(
                      value: 'pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'aceptada', child: Text('Aceptada')),
                  DropdownMenuItem(
                      value: 'rechazada', child: Text('Rechazada')),
                  DropdownMenuItem(
                      value: 'cancelada', child: Text('Cancelada')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!))
              : visits.isEmpty
                  ? const Center(child: Text("No tienes visitas agendadas."))
                  : RefreshIndicator(
                      onRefresh: vm.fetchMyVisits,
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: visits.length,
                          itemBuilder: (context, index) {
                            final visit = visits[index];
                            final property = Provider.of<PropertyViewModel>(
                                    context,
                                    listen: false)
                                .getPropertyById(visit.propertyId);

                            return GestureDetector(
                              onTap: () {
                                if (property != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PropertyDetailView(
                                        property: property,
                                        isOwner: false,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'No se encontró la propiedad')),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // --- Imagen ---
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: property?.photos.isNotEmpty == true
                                          ? Image.network(
                                              property!.photos.first,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.image,
                                                  size: 40, color: Colors.grey),
                                            ),
                                    ),

                                    // --- Contenido ---
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Estado + Precio
                                            Text(
                                              property?.title ?? 'Propiedad',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            // Título + ubicación
                                            Text(
                                              '${property?.propertyType ?? 'Propiedad'} · ${property?.city ?? ''}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              property?.address ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),

                                            const SizedBox(height: 18),

                                            // Fecha
                                            Text(
                                              'Visita: ${dateFormat.format(visit.requestedDateTime)}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              visit.status.toUpperCase(),
                                              style: TextStyle(
                                                  color: _buildStatusChip(
                                                      visit.status),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // --- Menú contextual ---
                                    if (visit.status == 'pendiente')
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'cancelar') {
                                            _confirmCancel(context, visit.id);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'cancelar',
                                            child: Text('Cancelar'),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
    );
  }
}
