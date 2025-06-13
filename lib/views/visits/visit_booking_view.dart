import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/widgets/shared/app_date_field.dart';
import '../../models/create_visit_request.dart';
import '../../viewmodels/visits_viewmodel.dart';

class VisitBookingView extends StatefulWidget {
  final String propertyId;
  final String ownerId;

  const VisitBookingView({
    super.key,
    required this.propertyId,
    required this.ownerId,
  });

  @override
  State<VisitBookingView> createState() => _VisitBookingViewState();
}

class _VisitBookingViewState extends State<VisitBookingView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? selectedDate;
  String? selectedHour;

  final List<String> hours = List.generate(10, (index) {
    final hour = index + 9;
    return '${hour.toString().padLeft(2, '0')}:00';
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VisitViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Agendar Visita",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detalles",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 24),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo de contacto',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono de contacto',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.length < 6
                    ? 'Teléfono inválido'
                    : null,
              ),
              const SizedBox(height: 16),

              // Fecha
              AppDateField(
                label: 'Fecha de visita',
                date: selectedDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                validator: (_) {
                  if (selectedDate == null) {
                    return 'Selecciona una fecha válida';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Hora
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Hora de visita',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: hours
                    .map((hour) => DropdownMenuItem(
                          value: hour,
                          child: Text(hour),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedHour = value),
                value: selectedHour,
                validator: (value) =>
                    value == null ? 'Selecciona una hora válida' : null,
              ),
              const SizedBox(height: 24),

              // Botón confirmar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (selectedDate == null || selectedHour == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Debes seleccionar fecha y hora')),
                            );
                            return;
                          }

                          final hourParts = selectedHour!.split(':');
                          final fullDateTime = DateTime.utc(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            int.parse(hourParts[0]),
                            int.parse(hourParts[1]),
                          );

                          final visit = CreateVisitRequest(
                            idProperty: widget.propertyId,
                            idOwnerUser: widget.ownerId,
                            contactEmail: _emailController.text.trim(),
                            contactPhone: _phoneController.text.trim(),
                            requestedDateTime: fullDateTime,
                          );

                          final success = await vm.createVisit(visit);

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Visita agendada exitosamente')),
                            );
                          } else {
                            final error = vm.errorMessage ??
                                'No se pudo agendar la visita.';
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Confirmar Visita"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
