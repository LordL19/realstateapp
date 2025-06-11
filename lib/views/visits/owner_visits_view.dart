import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/visits_viewmodel.dart';
import 'package:intl/intl.dart';

class OwnerVisitsView extends StatefulWidget {
  const OwnerVisitsView({super.key});

  @override
  State<OwnerVisitsView> createState() => _OwnerVisitsViewState();
}

class _OwnerVisitsViewState extends State<OwnerVisitsView> {
  @override
  void initState() {
    super.initState();
    Provider.of<VisitViewModel>(context, listen: false).fetchOwnerVisits();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Visitas para mis propiedades")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!))
              : vm.ownerVisits.isEmpty
                  ? const Center(child: Text("No tienes visitas agendadas."))
                  : ListView.builder(
                      itemCount: vm.ownerVisits.length,
                      itemBuilder: (context, index) {
                        final visit = vm.ownerVisits[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                                visit.propertyTitle ?? 'Propiedad sin título'),
                            subtitle: Text(
                              '${dateFormat.format(visit.requestedDateTime)}\nEstado: ${visit.status}',
                            ),
                            isThreeLine: true,
                            leading: const Icon(Icons.calendar_today),
                          ),
                        );
                      },
                    ),
    );
  }
}
