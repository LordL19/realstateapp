// lib/widgets/app_text_field.dart
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
      ),
      textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (!obscure) {
          // pasar al siguiente campo
          FocusScope.of(context).nextFocus();
        }
      },
    );
  }
}
