import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/create_property_input.dart';
import '../../viewmodels/property_viewmodel.dart';

class CreatePropertyView extends StatefulWidget {
  const CreatePropertyView({Key? key}) : super(key: key);

  @override
  _CreatePropertyViewState createState() => _CreatePropertyViewState();
}

class _CreatePropertyViewState extends State<CreatePropertyView> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _builtAreaController = TextEditingController();
  final _bedroomsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _builtAreaController.dispose();
    _bedroomsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final input = CreatePropertyInput(
      title: _titleController.text,
      description: _descriptionController.text,
      address: _addressController.text,
      city: _cityController.text,
      country: _countryController.text,
      propertyType: 'Casa', // Placeholder
      transactionType: 'Venta', // Placeholder
      price: double.tryParse(_priceController.text) ?? 0.0,
      area: int.tryParse(_areaController.text) ?? 0,
      builtArea: int.tryParse(_builtAreaController.text) ?? 0,
      bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
      photos: [], // Placeholder
    );

    final viewModel = context.read<PropertyViewModel>();
    final success = await viewModel.createProperty(input);

    if (mounted && success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Propiedad creada con éxito'),
            backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${viewModel.errorMessage}'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Resetear el estado del formulario al construir la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyViewModel>().resetFormState();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Propiedad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(_titleController, 'Título'),
              _buildTextField(_descriptionController, 'Descripción'),
              _buildTextField(_addressController, 'Dirección'),
              _buildTextField(_cityController, 'Ciudad'),
              _buildTextField(_countryController, 'País'),
              _buildTextField(_priceController, 'Precio',
                  keyboardType: TextInputType.number),
              _buildTextField(_areaController, 'Área (m²)',
                  keyboardType: TextInputType.number),
              _buildTextField(_builtAreaController, 'Área Construida (m²)',
                  keyboardType: TextInputType.number),
              _buildTextField(_bedroomsController, 'Habitaciones',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              Consumer<PropertyViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: viewModel.formState == PropertyFormStatus.loading
                        ? null
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: viewModel.formState == PropertyFormStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar Propiedad'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 