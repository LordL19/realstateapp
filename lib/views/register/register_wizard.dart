import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/viewmodels/auth_viewmodel.dart';
import 'package:realestate_app/views/register/steps/register_step_contact.dart';
import 'package:realestate_app/views/register/steps/register_step_credentials.dart';
import 'package:realestate_app/views/register/steps/register_step_profile.dart';

class RegisterFormWizard extends StatefulWidget {
  const RegisterFormWizard({super.key});

  @override
  State<RegisterFormWizard> createState() => _RegisterFormWizardState();
}

class _RegisterFormWizardState extends State<RegisterFormWizard> {
  int _step = 0;
  bool _isLoading = false;

  // Controllers compartidos
  final email = TextEditingController();
  final pwd = TextEditingController();
  final pwd2 = TextEditingController();
  final name = TextEditingController();
  final last = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController();

  // Estados simples
  String gender = 'M';
  DateTime? dob;

  // FormKeys
  final _formKeys =
      List<GlobalKey<FormState>>.generate(3, (_) => GlobalKey<FormState>());

  /* ───────── navegación ───────── */
  void _next() {
    // validar paso actual
    if (!_formKeys[_step].currentState!.validate()) return;
    if (_step == 1 && dob == null) {
      _showMsg('Selecciona la fecha de nacimiento');
      return;
    }
    if (_step == 2) {
      _submit();
      return;
    }
    setState(() => _step++);
  }

  void _back() => setState(() => _step = _step > 0 ? _step - 1 : 0);

  /* ───────── util ───────── */
  void _showMsg(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(m), backgroundColor: error ? Colors.red : null));

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => dob = d);
  }

  Future<void> _submit() async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.register(
      email: email.text.trim(),
      password: pwd.text.trim(),
      firstName: name.text.trim(),
      lastName: last.text.trim(),
      city: city.text.trim(),
      country: country.text.trim(),
      phoneNumber: phone.text.trim(),
      dateOfBirth: dob!.toIso8601String(),
      gender: gender,
    );

    setState(() => _isLoading = false);

    _showMsg(ok ? 'Registro exitoso' : vm.errorMessage ?? 'Error', error: !ok);
    if (ok && mounted) Navigator.pop(context);
  }

  /* ───────── build ───────── */
  @override
  Widget build(BuildContext context) {
    const stepLabels = ['Cuenta', 'Perfil', 'Contacto'];
    final pages = [
      CredentialsSection(
        formKey: _formKeys[0],
        email: email,
        pwd: pwd,
        pwd2: pwd2,
      ),
      ProfileSection(
        formKey: _formKeys[1],
        name: name,
        last: last,
        gender: gender,
        onGenderChanged: (v) => setState(() => gender = v),
        dob: dob,
        onPickDate: _pickDate,
      ),
      ContactSection(
        formKey: _formKeys[2],
        phone: phone,
        city: city,
        country: country,
      ),
    ];

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Registrarse',
            style: tt.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
          ),
          elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            /* indicador de pasos */
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xs,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Row(
                children: List.generate(stepLabels.length, (i) {
                  final selected = i == _step;
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs),
                          color: i <= _step
                              ? cs.primary
                              : cs.surfaceContainerHighest,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          stepLabels[i],
                          textAlign: TextAlign.center,
                          style: tt.labelLarge!.copyWith(
                            color: selected ? cs.primary : cs.onSurfaceVariant,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            /* contenido */
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.l),
                child: pages[_step],
              ),
            ),
          ],
        ),
      ),

      /* navegación inferior */
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.m,
            0,
            AppSpacing.m,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
          ),
          child: Row(
            children: [
              if (_step > 0)
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _back,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Atrás'),
                  style:
                      FilledButton.styleFrom(minimumSize: const Size(120, 48)),
                ),
              if (_step == 0) const SizedBox(width: 120),
              const Spacer(),
              SizedBox(
                width: 140,
                height: 48,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _next,
                        icon: Icon(
                          _step == 2 ? Icons.check : Icons.arrow_forward,
                        ),
                        label: Text(_step == 2 ? 'Registrar' : 'Siguiente'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [email, pwd, pwd2, name, last, phone, city, country]) {
      c.dispose();
    }
    super.dispose();
  }
}
