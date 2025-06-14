import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

enum FavoriteState { initial, loading, loaded, error, disposed }

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteService _service;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _ignoredKey = 'ignored_favs';

  FavoriteViewModel({FavoriteService? service})
      : _service = service ?? FavoriteService() {
    _loadIgnored();
  }

  FavoriteState _state = FavoriteState.initial;
  FavoriteState get state => _state;

  Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  // Favoritos que el usuario quitó localmente (hasta que se reinicie la app)
  final Set<String> _ignoredIds = {};

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> _loadIgnored() async {
    final raw = await _storage.read(key: _ignoredKey);
    if (raw != null) {
      _ignoredIds.addAll(List<String>.from(jsonDecode(raw)));
    }
  }

  Future<void> _persistIgnored() async {
    await _storage.write(
        key: _ignoredKey, value: jsonEncode(_ignoredIds.toList()));
  }

  Future<void> fetchFavorites() async {
    _state = FavoriteState.loading;
    notifyListeners();
    try {
      final ids = await _service.getFavoriteIds();
      _favoriteIds = ids.toSet().difference(_ignoredIds);
      _state = FavoriteState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = FavoriteState.error;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String propertyId) async {
    final bool wasAlreadyFavorite = _favoriteIds.contains(propertyId);

    // Optimistic update
    if (wasAlreadyFavorite) {
      _favoriteIds.remove(propertyId);
      _ignoredIds.add(propertyId);
      await _persistIgnored();
    } else {
      _favoriteIds.add(propertyId);
      _ignoredIds.remove(propertyId);
      await _persistIgnored();
    }
    notifyListeners();

    try {
      bool success;
      if (wasAlreadyFavorite) {
        // ✅ Usar DELETE si ya era favorito
        success = await _service.removeFavorite(propertyId);
      } else {
        // ➕ Usar POST si no era favorito
        success = await _service.addFavorite(propertyId);
      }

      if (!success) {
        throw Exception('La operación no fue exitosa');
      }

      // Actualiza solo cuando agregamos para reflejar correctamente cambios
      if (!wasAlreadyFavorite) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (_state != FavoriteState.disposed) {
          await fetchFavorites();
        }
      }
    } catch (e) {
      // Revertir cambio optimista
      if (wasAlreadyFavorite) {
        _favoriteIds.add(propertyId);
        _ignoredIds.remove(propertyId);
      } else {
        _favoriteIds.remove(propertyId);
        _ignoredIds.add(propertyId);
      }
      await _persistIgnored();
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void refresh() => notifyListeners();

  bool isFavorite(String propertyId) => _favoriteIds.contains(propertyId);

  @override
  void dispose() {
    _state = FavoriteState.disposed;
    super.dispose();
  }
}
