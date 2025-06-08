import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'profile_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final authVM = context.read<AuthViewModel>();
    
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await authVM.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        _showSnackBar("Login exitoso");
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileView()),
        );
      } else {
        _showSnackBar(authVM.errorMessage ?? "Error al iniciar sesión", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iniciar sesión"),
        elevation: 0,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _validateEmail(v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    validator: (v) => v != null && v.length >= 6 ? null : "Mínimo 6 caracteres",
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: authVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Iniciar sesión",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterView()),
                    ),
                    child: const Text("¿No tienes cuenta? Regístrate aquí"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty == true) return "Email requerido";
    if (value?.contains("@") != true || value?.contains(".") != true) {
      return "Email inválido";
    }
    return null;
  }
}