import 'package:flutter/material.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final FormFieldValidator<String>? validator;

  const AppDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final txt = date == null
        ? null
        : TextEditingController(text: date!.toLocal().toString().split(' ')[0]);

    return TextFormField(
      controller: txt,
      readOnly: true,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}
