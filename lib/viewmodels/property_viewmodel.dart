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
    return _properties.where((p) => !myPropertiesIds.contains(p.idProperty)).toList();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      final myPropertyIds = myPropertiesMinimal.map((p) => p.idProperty).toSet();
      
      // Obtener propiedades completas del listado general
      final completeProperties = _properties.where((p) => myPropertyIds.contains(p.idProperty)).toList();
      
      // Si algunas propiedades del usuario no están en la lista general, usar la versión mínima
      final completePropertyIds = completeProperties.map((p) => p.idProperty).toSet();
      final missingProperties = myPropertiesMinimal.where((p) => !completePropertyIds.contains(p.idProperty)).toList();
      
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
      _formState = success ? PropertyFormStatus.success : PropertyFormStatus.error;
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