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
      // Obtenemos ambas listas en paralelo para más eficiencia
      await Future.wait([
        _propertyService.getProperties(),
        fetchMyProperties(), // Reutilizamos el método que ya tenemos
      ]).then((results) {
        _properties = results[0] as List<Property>;
      });
      _state = PropertyState.loaded;
    } catch (e) {
      _state = PropertyState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMyProperties() async {
    _myPropertiesState = PropertyState.loading;
    notifyListeners();

    try {
      _myProperties = await _propertyService.getMyProperties();
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
      _properties.insert(0, newProperty); // Añadir al inicio de la lista
      _myProperties.insert(0, newProperty); // Añadir también a mis propiedades
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
        _myProperties.removeWhere((p) => p.idProperty == propertyId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void resetFormState() {
    _formState = PropertyFormStatus.initial;
  }
} 