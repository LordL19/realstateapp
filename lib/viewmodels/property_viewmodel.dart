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

  PropertyFormStatus _formState = PropertyFormStatus.initial;
  PropertyFormStatus get formState => _formState;

  List<Property> _properties = [];
  List<Property> get properties => _properties;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProperties() async {
    _state = PropertyState.loading;
    notifyListeners();

    try {
      _properties = await _propertyService.getProperties();
      _state = PropertyState.loaded;
    } catch (e) {
      _state = PropertyState.error;
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

  void resetFormState() {
    _formState = PropertyFormStatus.initial;
  }
} 