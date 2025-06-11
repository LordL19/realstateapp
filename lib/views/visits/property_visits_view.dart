import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/visits_viewmodel.dart';
import 'package:intl/intl.dart';

class PropertyVisitsView extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  const PropertyVisitsView(
      {super.key, required this.propertyId, required this.propertyTitle});

  @override
  State<PropertyVisitsView> createState() => _PropertyVisitsViewState();
}

class _PropertyVisitsViewState extends State<PropertyVisitsView> {
  @override
  void initState() {
    super.initState();
    Provider.of<VisitViewModel>(context, listen: false)
        .fetchPropertyVisits(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text("Visitas de ${widget.propertyTitle}")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!))
              : vm.propertyVisits.isEmpty
                  ? const Center(child: Text("No tienes visitas agendadas."))
                  : ListView.builder(
                      itemCount: vm.propertyVisits.length,
                      itemBuilder: (context, index) {
                        final visit = vm.propertyVisits[index];
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
