import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/create_property_input.dart';
import '../../models/property.dart';
import '../../services/image_upload_service.dart';
import '../../viewmodels/property_viewmodel.dart';

class PropertyFormView extends StatefulWidget {
  final Property? property; // Propiedad opcional para edición

  const PropertyFormView({Key? key, this.property}) : super(key: key);

  @override
  _PropertyFormViewState createState() => _PropertyFormViewState();
}

class _PropertyFormViewState extends State<PropertyFormView> {
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

  String? _selectedPropertyType;
  String? _selectedTransactionType;

  final List<String> _propertyTypes = ['Casa', 'Apartamento', 'Terreno', 'Local Comercial'];
  final List<String> _transactionTypes = ['Venta', 'Alquiler'];

  final _imageUploadService = ImageUploadService();
  final List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isUploading = false;
  bool get _isEditing => widget.property != null;

  // New lists for country & city selection
  final List<String> _countries = [
    'Argentina',
    'Bolivia',
    'Chile',
    'Colombia',
    'Ecuador',
    'España',
    'México',
    'Perú',
    'Uruguay',
    'Venezuela',
  ];

  final Map<String, List<String>> _citiesByCountry = {
    'Argentina': ['Buenos Aires', 'Córdoba', 'Rosario'],
    'Bolivia': ['La Paz', 'Santa Cruz', 'Cochabamba'],
    'Chile': ['Santiago', 'Valparaíso', 'Concepción'],
    'Colombia': ['Bogotá', 'Medellín', 'Cali'],
    'Ecuador': ['Quito', 'Guayaquil', 'Cuenca'],
    'España': ['Madrid', 'Barcelona', 'Valencia'],
    'México': ['Ciudad de México', 'Guadalajara', 'Monterrey'],
    'Perú': ['Lima', 'Arequipa', 'Cusco'],
    'Uruguay': ['Montevideo', 'Punta del Este', 'Salto'],
    'Venezuela': ['Caracas', 'Maracaibo', 'Valencia'],
  };

  String? _selectedCountry;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.property!;
      _titleController.text = p.title;
      _descriptionController.text = p.description ?? '';
      _addressController.text = p.address ?? '';
      _priceController.text = p.price.toString();
      _areaController.text = p.area.toString();
      _builtAreaController.text = p.builtArea.toString();
      _bedroomsController.text = p.bedrooms.toString();
      _existingImageUrls = List<String>.from(p.photos);

      // Safely pre-select dropdowns and update controllers
      _selectedCountry = _countries.contains(p.country) ? p.country : null;
      _countryController.text = _selectedCountry ?? '';

      if (_selectedCountry != null) {
        final cities = _citiesByCountry[_selectedCountry] ?? [];
        _selectedCity = cities.contains(p.city) ? p.city : null;
      } else {
        _selectedCity = null;
      }
      _cityController.text = _selectedCity ?? '';

      _selectedPropertyType = _propertyTypes.contains(p.propertyType) ? p.propertyType : null;
      _selectedTransactionType = _transactionTypes.contains(p.transactionType) ? p.transactionType : null;
    }
  }

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

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final totalImageCount = _selectedImages.length + _existingImageUrls.length;
    if (totalImageCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona al menos una imagen.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);

    final List<String> newImageUrls = [];
    for (var image in _selectedImages) {
      final url = await _imageUploadService.uploadImage(image);
      if (url != null) {
        newImageUrls.add(url);
      }
    }
    
    if(newImageUrls.length != _selectedImages.length) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al subir una o más imágenes nuevas.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final finalImageUrls = [..._existingImageUrls, ...newImageUrls];

    final input = CreatePropertyInput(
      title: _titleController.text,
      description: _descriptionController.text,
      address: _addressController.text,
      city: _cityController.text,
      country: _countryController.text,
      propertyType: _selectedPropertyType!,
      transactionType: _selectedTransactionType!,
      price: double.tryParse(_priceController.text) ?? 0.0,
      area: int.tryParse(_areaController.text) ?? 0,
      builtArea: int.tryParse(_builtAreaController.text) ?? 0,
      bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
      photos: finalImageUrls,
    );

    final viewModel = context.read<PropertyViewModel>();
    bool success = false;

    if (_isEditing) {
      success = await viewModel.updateProperty(widget.property!.idProperty, input);
    } else {
      success = await viewModel.createProperty(input);
    }
    
    setState(() => _isUploading = false);

    if (mounted && success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Propiedad ${_isEditing ? 'actualizada' : 'creada'} con éxito'),
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

  Widget _buildDropdown(List<String> items, String label, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Campo requerido' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Propiedad' : 'Crear Propiedad'),
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
              // Country dropdown comes before city dropdown
              _buildDropdown(_countries, 'País', _selectedCountry, (value) {
                setState(() {
                  _selectedCountry = value;
                  _countryController.text = value ?? '';
                  // Reset city when country changes
                  _selectedCity = null;
                  _cityController.text = '';
                });
              }),
              if (_selectedCountry != null)
                _buildDropdown(
                    _citiesByCountry[_selectedCountry!] ?? [],
                    'Ciudad',
                    _selectedCity,
                    (value) {
                      setState(() {
                        _selectedCity = value;
                        _cityController.text = value ?? '';
                      });
                    }),
              _buildDropdown(_propertyTypes, 'Tipo de Propiedad', _selectedPropertyType, (value) => setState(() => _selectedPropertyType = value)),
              _buildDropdown(_transactionTypes, 'Tipo de Transacción', _selectedTransactionType, (value) => setState(() => _selectedTransactionType = value)),
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
                        : Text(_isEditing ? 'Guardar Cambios' : 'Crear Propiedad'),
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
          child: (_existingImageUrls.isEmpty && _selectedImages.isEmpty)
              ? const Center(child: Text('Ninguna imagen seleccionada.'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageUrls.length + _selectedImages.length,
                  itemBuilder: (context, index) {
                    bool isExistingImage = index < _existingImageUrls.length;
                    ImageProvider image;
                    VoidCallback onRemove;

                    if (isExistingImage) {
                      image = NetworkImage(_existingImageUrls[index]);
                      onRemove = () => _removeExistingImage(index);
                    } else {
                      final newImageIndex = index - _existingImageUrls.length;
                      final imageFile = _selectedImages[newImageIndex];
                      image = kIsWeb
                          ? NetworkImage(imageFile.path)
                          : FileImage(File(imageFile.path)) as ImageProvider;
                      onRemove = () => _removeNewImage(newImageIndex);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: image, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: onRemove,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Añadir Imágenes'),
        ),
      ],
    );
  }
} 