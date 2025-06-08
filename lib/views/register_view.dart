import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _gender = "M";
  DateTime? _dateOfBirth;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _addValidationListeners();
  }

  void _addValidationListeners() {
    final controllers = [
      _emailController,
      _passwordController,
      _firstNameController,
      _lastNameController,
      _phoneController,
    ];
    
    for (final controller in controllers) {
      controller.addListener(_validateForm);
    }
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateForm);
    _lastNameController.removeListener(_validateForm);
    _firstNameController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha de nacimiento',
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _register() async {
    final vm = context.read<AuthViewModel>();
    
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      _showSnackBar("Selecciona la fecha de nacimiento", isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final success = await vm.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth!.toIso8601String(),
        gender: _gender,
      );

      if (mounted) {
        if (success) {
          _showSnackBar("Registro exitoso");
          Navigator.of(context).pop();
        } else {
          _showSnackBar(vm.errorMessage ?? "Error al registrarse", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error inesperado al registrarse", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrarse"),
        elevation: 0,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _firstNameController,
                    label: "Nombre",
                    icon: Icons.person,
                    validator: (v) => v?.isEmpty == true ? "Requerido" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: "Apellido",
                    icon: Icons.person_outline,
                    validator: (v) => v?.isEmpty == true ? "Requerido" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => _validateEmail(v),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (v) => v != null && v.length >= 6 ? null : "Mínimo 6 caracteres",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: "Teléfono",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty == true ? "Requerido" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildGenderSelector(),
                  const SizedBox(height: 20),
                  _buildDateSelector(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cityController,
                    label: "Ciudad",
                    icon: Icons.location_city,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _countryController,
                    label: "País",
                    icon: Icons.flag,
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(vm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: TextInputAction.next,
    );
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty == true) return "Requerido";
    if (value?.contains("@") != true || value?.contains(".") != true) {
      return "Email inválido";
    }
    return null;
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Género",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Masculino"),
                value: "M",
                groupValue: _gender,
                onChanged: (val) => setState(() => _gender = val!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Femenino"),
                value: "F",
                groupValue: _gender,
                onChanged: (val) => setState(() => _gender = val!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateOfBirth == null
                  ? "Seleccionar fecha de nacimiento"
                  : "Nacimiento: ${_dateOfBirth!.toLocal().toString().split(' ')[0]}",
              style: TextStyle(
                fontSize: 16,
                color: _dateOfBirth == null ? Colors.grey[600] : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AuthViewModel vm) {
    return SizedBox(
      height: 48,
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Registrarse",
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}