import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/widgets/animations/fade_in.dart';
import 'package:realestate_app/widgets/shared/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'main_tab_view.dart';
import 'register/register_wizard.dart';
import 'package:lottie/lottie.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _submitted = true);

    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthViewModel>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    final msg =
        success ? 'Login exitoso' : auth.errorMessage ?? 'Error inesperado';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), backgroundColor: success ? null : Colors.red),
      );
    }

    if (success && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainTabView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Consumer<AuthViewModel>(
        builder: (_, auth, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Lottie.network(
                    'https://lottie.host/b0112925-f172-4c0c-be98-255b5ccc815b/76F3kTdmrM.json',
                    width: 240,
                    fit: BoxFit.contain,
                    repeat: false),
                const SizedBox(height: AppSpacing.l),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'HomeHunt',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    'Encuentra tu próximo hogar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: AppTextField(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    validator: (v) {
                      if ((v ?? '').isEmpty) return 'Requerido';
                      if (!v!.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                FadeIn(
                  delay: const Duration(milliseconds: 800),
                  child: AppTextField(
                    controller: _passwordCtrl,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscure: !_showPassword,
                    suffix: IconButton(
                      icon: Icon(_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    validator: (v) =>
                        (v?.length ?? 0) >= 6 ? null : 'Mínimo 6 caracteres',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FadeIn(
                  delay: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSpacing.xxxl,
                    child: auth.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Iniciar sesión'),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                FadeIn(
                  delay: const Duration(milliseconds: 1200),
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterFormWizard()),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
