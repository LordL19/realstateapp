import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/create_property_input.dart';
import '../models/property.dart';
import '../services/property_service.dart';

enum PropertyState { initial, loading, loaded, error }

enum PropertyFormStatus { initial, loading, success, error }

class PropertyViewModel extends ChangeNotifier {
  final PropertyService _propertyService;

  PropertyViewModel({required GraphQLClient client})
      : _propertyService = PropertyService(client: client);

  PropertyState _state = PropertyState.initial;
  PropertyState get state => _state;

  PropertyState _myPropertiesState = PropertyState.initial;
  PropertyState get myPropertiesState => _myPropertiesState;

  PropertyFormStatus _formState = PropertyFormStatus.initial;
  PropertyFormStatus get formState => _formState;

  List<Property> _properties = [];
  List<Property> get properties => _properties;

  List<Property> _myProperties = [];
  List<Property> get myProperties => _myProperties;

  // Nueva lista filtrada para la vista principal
  List<Property> get publicProperties {
    if (myProperties.isEmpty) return _properties;
    final myPropertiesIds = _myProperties.map((p) => p.idProperty).toSet();
    return _properties
        .where((p) => !myPropertiesIds.contains(p.idProperty))
        .toList();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- START: Filter State ---
  String? _searchQuery;
  String _searchType = 'Nombre';
  String? _selectedPropertyType;
  int? _minBedrooms;
  int? _minTotalArea;
  int? _minBuiltArea;

  // Nuevos filtros
  String? _selectedCountry;
  String? _selectedCity;
  double? _minPrice;
  double? _maxPrice;

  String get searchQuery => _searchQuery ?? '';
  String get searchType => _searchType;
  String? get selectedPropertyType => _selectedPropertyType;
  int? get minBedrooms => _minBedrooms;
  int? get minTotalArea => _minTotalArea;
  int? get minBuiltArea => _minBuiltArea;
  String? get selectedCountry => _selectedCountry;
  String? get selectedCity => _selectedCity;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  /// Indica si alguno de los filtros está activo
  bool get hasActiveFilters =>
      // texto de búsqueda
      (_searchQuery?.isNotEmpty ?? false) ||
      // tipo de propiedad
      _selectedPropertyType != null ||
      // dormitorios / áreas
      (_minBedrooms != null && _minBedrooms! > 0) ||
      (_minTotalArea != null && _minTotalArea! > 0) ||
      (_minBuiltArea != null && _minBuiltArea! > 0) ||
      // país / ciudad
      _selectedCountry != null ||
      _selectedCity != null ||
      // rango de precios
      (_minPrice != null && _minPrice! > 0) ||
      (_maxPrice != null && _maxPrice! > 0);

  // Lista de países y ciudades como en property_form_view
  final List<String> countries = [
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

  final Map<String, List<String>> citiesByCountry = {
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

  List<String> getCitiesForCountry(String? country) {
    if (country == null) return [];
    return citiesByCountry[country] ?? [];
  }

  void refresh() => notifyListeners();

  void updateSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSearchType(String type) {
    _searchType = type;
    notifyListeners();
  }

  void updatePropertyTypeFilter(String? type) {
    _selectedPropertyType = type;
    notifyListeners();
  }

  void updateMinBedrooms(String? value) {
    _minBedrooms = int.tryParse(value ?? '');
    notifyListeners();
  }

  void updateMinTotalArea(String? value) {
    _minTotalArea = int.tryParse(value ?? '');
    notifyListeners();
  }

  void updateMinBuiltArea(String? value) {
    _minBuiltArea = int.tryParse(value ?? '');
    notifyListeners();
  }

  void updateCountry(String? country) {
    _selectedCountry = country;
    // Si cambia el país, reseteamos la ciudad
    if (_selectedCity != null && country != null) {
      final cities = getCitiesForCountry(country);
      if (!cities.contains(_selectedCity)) {
        _selectedCity = null;
      }
    }
    notifyListeners();
  }

  void updateCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void updateMinPrice(String? value) {
    _minPrice = double.tryParse(value ?? '');
    notifyListeners();
  }

  void updateMaxPrice(String? value) {
    _maxPrice = double.tryParse(value ?? '');
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _searchType = 'Nombre';
    _selectedPropertyType = null;
    _minBedrooms = null;
    _minTotalArea = null;
    _minBuiltArea = null;
    _selectedCountry = null;
    _selectedCity = null;
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }

  List<Property> applyFilters(List<Property> properties) {
    List<Property> filtered = List.from(properties);

    if (_selectedPropertyType != null && _selectedPropertyType!.isNotEmpty) {
      filtered = filtered
          .where((p) => p.propertyType == _selectedPropertyType)
          .toList();
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      switch (_searchType) {
        case 'Nombre':
          filtered = filtered
              .where((p) => p.title.toLowerCase().contains(query))
              .toList();
          break;
        case 'Zona':
          filtered = filtered
              .where((p) =>
                  (p.address?.toLowerCase().contains(query) ?? false) ||
                  p.city.toLowerCase().contains(query) ||
                  p.country.toLowerCase().contains(query))
              .toList();
          break;
        case 'País':
          filtered = filtered
              .where((p) => p.country.toLowerCase().contains(query))
              .toList();
          break;
        case 'Ciudad':
          filtered = filtered
              .where((p) => p.city.toLowerCase().contains(query))
              .toList();
          break;
      }
    }

    // Filtro por país y ciudad
    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      filtered = filtered.where((p) => p.country == _selectedCountry).toList();

      // Sólo filtramos por ciudad si hay un país seleccionado
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        filtered = filtered.where((p) => p.city == _selectedCity).toList();
      }
    }

    // Filtro por rango de precios
    if (_minPrice != null && _minPrice! > 0) {
      filtered = filtered.where((p) => p.price >= _minPrice!).toList();
    }
    if (_maxPrice != null && _maxPrice! > 0) {
      filtered = filtered.where((p) => p.price <= _maxPrice!).toList();
    }

    if (_minBedrooms != null && _minBedrooms! > 0) {
      filtered = filtered.where((p) => p.bedrooms >= _minBedrooms!).toList();
    }
    if (_minTotalArea != null && _minTotalArea! > 0) {
      filtered = filtered.where((p) => p.area >= _minTotalArea!).toList();
    }
    if (_minBuiltArea != null && _minBuiltArea! > 0) {
      filtered = filtered.where((p) => p.builtArea >= _minBuiltArea!).toList();
    }

    return filtered;
  }
  // --- END: Filter State ---

  Future<void> fetchProperties() async {
    _state = PropertyState.loading;
    notifyListeners();

    try {
      // Cargar todas las propiedades primero
      _properties = await _propertyService.getProperties();
      _state = PropertyState.loaded;

      // Luego cargar mis propiedades usando la nueva lógica
      await fetchMyProperties();
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMyProperties() async {
    _myPropertiesState = PropertyState.loading;
    notifyListeners();

    try {
      // Primero, asegurarse de que tenemos todas las propiedades cargadas
      if (_properties.isEmpty) {
        // Cargar propiedades si aún no están cargadas
        _properties = await _propertyService.getProperties();
      }

      // Obtener solo los IDs y datos mínimos de mis propiedades
      final myPropertiesMinimal = await _propertyService.getMyProperties();

      // Crear un conjunto de IDs de mis propiedades
      final myPropertyIds =
          myPropertiesMinimal.map((p) => p.idProperty).toSet();

      // Obtener propiedades completas del listado general
      final completeProperties = _properties
          .where((p) => myPropertyIds.contains(p.idProperty))
          .toList();

      // Si algunas propiedades del usuario no están en la lista general, usar la versión mínima
      final completePropertyIds =
          completeProperties.map((p) => p.idProperty).toSet();
      final missingProperties = myPropertiesMinimal
          .where((p) => !completePropertyIds.contains(p.idProperty))
          .toList();

      // Combinar propiedades completas con las faltantes
      _myProperties = [...completeProperties, ...missingProperties];

      // Ordenar por fecha de actualización para mantener consistencia
      _myProperties.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      _myPropertiesState = PropertyState.loaded;
    } catch (e) {
      _myPropertiesState = PropertyState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createProperty(CreatePropertyInput input) async {
    _formState = PropertyFormStatus.loading;
    notifyListeners();
    try {
      final newProperty = await _propertyService.createProperty(input);
      // Add to both lists
      _properties.insert(0, newProperty);
      _myProperties.insert(0, newProperty);
      _formState = PropertyFormStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _formState = PropertyFormStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProperty(String propertyId) async {
    try {
      final success = await _propertyService.deleteProperty(propertyId);
      if (success) {
        // Remove from both lists
        _myProperties.removeWhere((p) => p.idProperty == propertyId);
        _properties.removeWhere((p) => p.idProperty == propertyId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProperty(String id, CreatePropertyInput input) async {
    _formState = PropertyFormStatus.loading;
    notifyListeners();
    try {
      final success = await _propertyService.updateProperty(id, input);
      if (success) {
        // After successful update, reload properties from server to get fresh data
        await fetchProperties();
      }
      _formState =
          success ? PropertyFormStatus.success : PropertyFormStatus.error;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _formState = PropertyFormStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetFormState() {
    _formState = PropertyFormStatus.initial;
  }
}
