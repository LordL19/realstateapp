import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/visits_viewmodel.dart';

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
    Provider.of<VisitViewModel>(context, listen: false)
        .fetchPropertyVisits(widget.propertyId);
  }

  Future<void> _changeStatus(
      BuildContext context, String visitId, String newStatus) async {
    final vm = context.read<VisitViewModel>();
    final success = await vm.updateVisitStatus(visitId, newStatus);
    if (!mounted) return;

    if (success) {
      await vm.fetchPropertyVisits(widget.propertyId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Visita ${newStatus.toUpperCase()}'
              : vm.errorMessage ?? 'Error al cambiar el estado',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

    final visits = vm.propertyVisits
        .where((visit) =>
            selectedStatus == 'todas' || visit.status == selectedStatus)
        .toList()
      ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));

    return Scaffold(
      appBar: AppBar(
        title: Text("Visitas de ${widget.propertyTitle}"),
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
                      itemCount: visits.length,
                      itemBuilder: (context, index) {
                        final visit = visits[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                                visit.propertyTitle ?? 'Propiedad sin título'),
                            subtitle: Text(
                              '${dateFormat.format(visit.requestedDateTime)}\nEstado: ${visit.status}',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                _changeStatus(context, visit.id, value);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'aceptada',
                                  child: Text('Aceptar'),
                                ),
                                const PopupMenuItem(
                                  value: 'rechazada',
                                  child: Text('Rechazar'),
                                ),
                                const PopupMenuItem(
                                  value: 'cancelada',
                                  child: Text('Cancelar'),
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
