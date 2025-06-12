import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/visits_viewmodel.dart';
import 'package:intl/intl.dart';

class MyVisitsView extends StatefulWidget {
  const MyVisitsView({super.key});

  @override
  State<MyVisitsView> createState() => _MyVisitsViewState();
}

class _MyVisitsViewState extends State<MyVisitsView> {
  @override
  void initState() {
    super.initState();
    Provider.of<VisitViewModel>(context, listen: false).fetchMyVisits();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Visitas")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!))
              : vm.myVisits.isEmpty
                  ? const Center(child: Text("No tienes visitas agendadas."))
                  : ListView.builder(
                      itemCount: vm.myVisits.length,
                      itemBuilder: (context, index) {
                        final visit = vm.myVisits[index];
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
