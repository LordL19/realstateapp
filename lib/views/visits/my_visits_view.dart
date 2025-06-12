import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    Provider.of<VisitViewModel>(context, listen: false).fetchMyVisits();
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
      final success = await vm.cancelVisit(id);
      await vm.fetchMyVisits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

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
                  ? const Center(child: Text("No tienes visitas agendadas."))
                  : RefreshIndicator(
                      onRefresh: vm.fetchMyVisits,
                      child: ListView.builder(
                        itemCount: visits.length,
                        itemBuilder: (context, index) {
                          final visit = visits[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.house_outlined),
                              title: Text(
                                visit.propertyTitle ?? 'Propiedad sin título',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fecha: ${dateFormat.format(visit.requestedDateTime)}',
                                  ),
                                  Text('Estado: ${visit.status}'),
                                ],
                              ),
                              trailing: visit.status == 'pendiente'
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      tooltip: 'Cancelar visita',
                                      onPressed: () =>
                                          _confirmCancel(context, visit.id),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
