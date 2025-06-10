import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/create_property_input.dart';
import '../../services/image_upload_service.dart';
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

  final _imageUploadService = ImageUploadService();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;

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

  Future<void> _pickImages() async {
    final images = await _imageUploadService.pickMultipleImages();
    setState(() {
      _selectedImages.addAll(images);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona al menos una imagen.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);

    final List<String> imageUrls = [];
    for (var image in _selectedImages) {
      final url = await _imageUploadService.uploadImage(image);
      if (url != null) {
        imageUrls.add(url);
      }
    }
    
    if(imageUrls.length != _selectedImages.length) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al subir una o más imágenes.'),
            backgroundColor: Colors.red),
      );
      return;
    }

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
      photos: imageUrls, // Usamos la lista de URLs de las imágenes subidas
    );

    final viewModel = context.read<PropertyViewModel>();
    final success = await viewModel.createProperty(input);
    
    setState(() => _isUploading = false);

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
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : [],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo requerido';
          }
          return null;
        },
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
              const Text('Información de la Propiedad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('Imágenes de la Propiedad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePicker(),
              const SizedBox(height: 20),
              Consumer<PropertyViewModel>(
                builder: (context, viewModel, child) {
                  final isLoading = viewModel.formState == PropertyFormStatus.loading || _isUploading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
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

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 120,
          child: _selectedImages.isEmpty
              ? const Center(child: Text('Ninguna imagen seleccionada.'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(_selectedImages[index].path)
                                    : FileImage(File(_selectedImages[index].path))
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Añadir Imágenes'),
        ),
      ],
    );
  }
} 