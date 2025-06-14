import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:realestate_app/theme/theme.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../../viewmodels/visits_viewmodel.dart';
import '../properties/property_detail_view.dart';

class AllVisitsView extends StatefulWidget {
  const AllVisitsView({super.key});

  @override
  State<AllVisitsView> createState() => _AllVisitsViewState();
}

class _AllVisitsViewState extends State<AllVisitsView> {
  int _segment = 0;
  String selectedStatus = 'todas';

  @override
  void initState() {
    super.initState();
    final visitVM = context.read<VisitViewModel>();
    final propVM = context.read<PropertyViewModel>();
    visitVM.fetchMyVisits();
    visitVM.fetchOwnerVisits();
    propVM.fetchProperties();
  }

  Future<void> _cancelVisit(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancelar Visita"),
        content: const Text("¿Estás seguro de cancelar esta visita?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sí, cancelar")),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final vm = context.read<VisitViewModel>();
      final success = await vm.cancelVisit(id);
      if (success) await vm.fetchMyVisits();
    }
  }

  Future<void> _changeStatus(String id, String newStatus) async {
    final vm = context.read<VisitViewModel>();
    final success = await vm.updateVisitStatus(id, newStatus);
    if (success) await vm.fetchOwnerVisits();
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

    final visits = (_segment == 0 ? vm.myVisits : vm.ownerVisits)
        .where((v) => selectedStatus == 'todas' || v.status == selectedStatus)
        .toList()
      ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tours de propiedades',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.calendar_today),
                    label: Text('Agendados'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.home_work),
                    label: Text('Recibidos'),
                  ),
                ],
                selected: {_segment},
                onSelectionChanged: (s) => setState(() => _segment = s.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  minimumSize:
                      WidgetStateProperty.all(const Size(double.infinity, 48)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : visits.isEmpty
                    ? const Center(child: Text('No hay tours con ese estado.'))
                    : RefreshIndicator(
                        onRefresh: _segment == 0
                            ? vm.fetchMyVisits
                            : vm.fetchOwnerVisits,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: visits.length,
                          itemBuilder: (context, index) {
                            final visit = visits[index];
                            final property =
                                propVM.getPropertyById(visit.propertyId);

                            return GestureDetector(
                              onTap: () {
                                if (property != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PropertyDetailView(
                                          property: property,
                                          isOwner:
                                              _segment == 0 ? false : true),
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
                                  height: _segment == 0 ? 140 : 190,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                          left: Radius.circular(12),
                                        ),
                                        child: property?.photos.isNotEmpty ==
                                                true
                                            ? Image.network(
                                                property!.photos.first,
                                                width: 120,
                                                height:
                                                    _segment == 0 ? 140 : 190,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 120,
                                                height: 120,
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
                                                    color:
                                                        Colors.grey.shade700),
                                              ),
                                              Text(
                                                property?.address ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                              const SizedBox(height: 10),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'Fecha: ${dateFormat.format(visit.requestedDateTime)}',
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                              if (_segment == 1) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Contacto: ${visit.contactPhone}',
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                                Text(
                                                  visit.contactEmail,
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 4),
                                              Text(
                                                visit.status.toUpperCase(),
                                                style: TextStyle(
                                                  color: _statusColor(
                                                      visit.status),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_segment == 0 &&
                                          visit.status == 'aceptada')
                                        PopupMenuButton<String>(
                                          onSelected: (v) =>
                                              _cancelVisit(visit.id),
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'cancelar',
                                              child: Text('Cancelar'),
                                            ),
                                          ],
                                        ),
                                      if (_segment == 1 &&
                                          visit.status != "rechazada")
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
          ),
        ],
      ),
    );
  }
}
