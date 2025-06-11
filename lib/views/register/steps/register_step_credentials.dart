import 'package:flutter/material.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';

class CredentialsSection extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email, pwd, pwd2;

  const CredentialsSection({
    super.key,
    required this.formKey,
    required this.email,
    required this.pwd,
    required this.pwd2,
  });

  @override
  _CredentialsSectionState createState() => _CredentialsSectionState();
}

class _CredentialsSectionState extends State<CredentialsSection> {
  bool _showPwd1 = false;
  bool _showPwd2 = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.l,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cuenta', style: tt.headlineMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Crea las credenciales de acceso.',
              style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              controller: widget.email,
              label: 'Email',
              icon: Icons.email,
              validator: (v) => v!.contains('@') ? null : 'Email inválido',
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              controller: widget.pwd,
              label: 'Contraseña',
              icon: Icons.lock,
              obscure: !_showPwd1,
              suffix: IconButton(
                icon: Icon(
                  _showPwd1 ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() {
                  _showPwd1 = !_showPwd1;
                }),
              ),
              validator: (v) => v!.length >= 6 ? null : 'Mínimo 6 caracteres',
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              controller: widget.pwd2,
              label: 'Confirmar contraseña',
              icon: Icons.lock_outline,
              obscure: !_showPwd2,
              suffix: IconButton(
                icon: Icon(
                  _showPwd2 ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() {
                  _showPwd2 = !_showPwd2;
                }),
              ),
              validator: (v) => v == widget.pwd.text ? null : 'No coincide',
            ),
          ],
        ),
      ),
    );
  }
}
