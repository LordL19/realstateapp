import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/property_viewmodel.dart';

class PropertyFilterHeader extends StatefulWidget {
  const PropertyFilterHeader({Key? key}) : super(key: key);

  @override
  _PropertyFilterHeaderState createState() => _PropertyFilterHeaderState();
}

class _PropertyFilterHeaderState extends State<PropertyFilterHeader> {
  final _searchController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _builtAreaController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<PropertyViewModel>(context, listen: false);
    _searchController.text = viewModel.searchQuery;
    _bedroomsController.text = viewModel.minBedrooms?.toString() ?? '';
    _totalAreaController.text = viewModel.minTotalArea?.toString() ?? '';
    _builtAreaController.text = viewModel.minBuiltArea?.toString() ?? '';
    _minPriceController.text = viewModel.minPrice?.toString() ?? '';
    _maxPriceController.text = viewModel.maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bedroomsController.dispose();
    _totalAreaController.dispose();
    _builtAreaController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearAllFilters(PropertyViewModel viewModel) {
    viewModel.clearFilters();
    _searchController.clear();
    _bedroomsController.clear();
    _totalAreaController.clear();
    _builtAreaController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PropertyViewModel>(context);
    const propertyTypes = ['Casa', 'Apartamento', 'Terreno', 'Local Comercial'];
    const searchTypes = ['Nombre', 'Zona', 'País', 'Ciudad'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ExpansionTile(
        title: const Text('Filtros y Búsqueda', style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearch(viewModel, searchTypes),
                const SizedBox(height: 12),
                _buildCountryAndCityFilters(viewModel),
                const SizedBox(height: 12),
                _buildDropdown(
                  context,
                  'Tipo de Propiedad',
                  propertyTypes,
                  viewModel.selectedPropertyType,
                  (value) => viewModel.updatePropertyTypeFilter(value),
                ),
                const SizedBox(height: 12),
                _buildPriceRangeFilter(viewModel),
                const SizedBox(height: 12),
                _buildNumericFilters(viewModel),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _clearAllFilters(viewModel),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar Filtros'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(PropertyViewModel viewModel, List<String> searchTypes) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            onChanged: viewModel.updateSearchQuery,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _buildDropdown(
            context,
            'Por',
            searchTypes,
            viewModel.searchType,
            (value) => viewModel.updateSearchType(value!),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCountryAndCityFilters(PropertyViewModel viewModel) {
    final cities = viewModel.selectedCountry != null 
        ? viewModel.getCitiesForCountry(viewModel.selectedCountry)
        : <String>[];
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdown(
          context,
          'País',
          viewModel.countries,
          viewModel.selectedCountry,
          (value) => viewModel.updateCountry(value),
        ),
        if (viewModel.selectedCountry != null) ...[
          const SizedBox(height: 8),
          _buildDropdown(
            context,
            'Ciudad',
            cities,
            viewModel.selectedCity,
            (value) => viewModel.updateCity(value),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPriceRangeFilter(PropertyViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            decoration: const InputDecoration(
              labelText: 'Precio Mín.',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: viewModel.updateMinPrice,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            decoration: const InputDecoration(
              labelText: 'Precio Máx.',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: viewModel.updateMaxPrice,
          ),
        ),
      ],
    );
  }

  Widget _buildNumericFilters(PropertyViewModel viewModel) {
    return Row(
      children: [
        Expanded(child: _buildNumericField(_bedroomsController, 'Hab.', viewModel.updateMinBedrooms)),
        const SizedBox(width: 8),
        Expanded(child: _buildNumericField(_totalAreaController, 'Área m²', viewModel.updateMinTotalArea)),
        const SizedBox(width: 8),
        Expanded(child: _buildNumericField(_builtAreaController, 'Área Const. m²', viewModel.updateMinBuiltArea)),
      ],
    );
  }
  
  Widget _buildNumericField(TextEditingController controller, String label, ValueChanged<String?> onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }
} 