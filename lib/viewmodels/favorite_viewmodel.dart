import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

enum FavoriteState { initial, loading, loaded, error }

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteService _service;

  FavoriteViewModel({FavoriteService? service}) : _service = service ?? FavoriteService();

  FavoriteState _state = FavoriteState.initial;
  FavoriteState get state => _state;

  Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFavorites() async {
    _state = FavoriteState.loading;
    notifyListeners();
    try {
      final ids = await _service.getFavoriteIds();
      _favoriteIds = ids.toSet();
      _state = FavoriteState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = FavoriteState.error;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String propertyId) async {
    try {
      if (_favoriteIds.contains(propertyId)) {
        await _service.removeFavorite(propertyId);
        _favoriteIds.remove(propertyId);
      } else {
        await _service.addFavorite(propertyId);
        _favoriteIds.add(propertyId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool isFavorite(String propertyId) => _favoriteIds.contains(propertyId);
} 