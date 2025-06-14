import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/visits_viewmodel.dart';

class OwnerVisitsView extends StatefulWidget {
  const OwnerVisitsView({super.key});

  @override
  State<OwnerVisitsView> createState() => _OwnerVisitsViewState();
}

class _OwnerVisitsViewState extends State<OwnerVisitsView> {
  String selectedStatus = 'todas';

  @override
  void initState() {
    super.initState();
    Provider.of<VisitViewModel>(context, listen: false).fetchOwnerVisits();
  }

  Future<void> _changeStatus(
      BuildContext context, String visitId, String newStatus) async {
    final vm = context.read<VisitViewModel>();
    final success = await vm.updateVisitStatus(visitId, newStatus);
    if (!mounted) return;

    if (success) {
      await vm.fetchOwnerVisits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

    final visits = vm.ownerVisits
        .where((visit) =>
            selectedStatus == 'todas' || visit.status == selectedStatus)
        .toList()
      ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitas para mis propiedades"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                icon: const Icon(Icons.filter_list, color: Colors.white),
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
                  ? const Center(child: Text("No hay visitas con ese estado."))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: visits.length,
                      itemBuilder: (context, index) {
                        final visit = visits[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        visit.propertyTitle ??
                                            'Propiedad sin título',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Fecha: ${dateFormat.format(visit.requestedDateTime)}'),
                                      Text('Contacto: ${visit.contactPhone}'),
                                      Text('Email: ${visit.contactEmail}'),
                                      const SizedBox(height: 8),
                                      Chip(
                                        label: Text(visit.status),
                                        backgroundColor:
                                            Colors.orange.shade100,
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) =>
                                      _changeStatus(context, visit.id, value),
                                  itemBuilder: (context) => [
                                    if (visit.status == 'pendiente') ...[
                                      const PopupMenuItem(
                                          value: 'aceptada',
                                          child: Text('Aceptar')),
                                      const PopupMenuItem(
                                          value: 'rechazada',
                                          child: Text('Rechazar')),
                                    ],
                                    if (visit.status == 'aceptada')
                                      const PopupMenuItem(
                                          value: 'cancelada',
                                          child: Text('Cancelar')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
