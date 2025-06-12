import 'package:flutter/material.dart';
import '../models/visit_history_model.dart';
import '../models/create_visit_history_request.dart';
import '../models/user_info_model.dart';
import '../services/visit_history_service.dart';
import '../services/user_service.dart';

class VisitHistoryViewModel extends ChangeNotifier {
  final VisitHistoryService _service = VisitHistoryService();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<VisitHistory> _userVisitHistory = [];
  List<VisitHistory> _propertyVisitHistory = [];
  List<VisitHistory> _recommendations = [];
  Map<String, UserInfo> _usersCache = {};
  UserInfo? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<VisitHistory> get userVisitHistory => _userVisitHistory;
  List<VisitHistory> get propertyVisitHistory => _propertyVisitHistory;
  List<VisitHistory> get recommendations => _recommendations;
  Map<String, UserInfo> get usersCache => _usersCache;
  UserInfo? get currentUser => _currentUser;

  // Get current user info
  Future<UserInfo?> _loadCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    try {
      _currentUser = await _userService.getCurrentUser();
      return _currentUser;
    } catch (e) {
      print('Error loading current user: $e');
      return null;
    }
  }

  // Record a new visit
  Future<bool> recordVisit(CreateVisitHistoryRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.recordVisit(request);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch user's visit history
  Future<void> fetchUserVisitHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load the current user first
      await _loadCurrentUser();
      
      _userVisitHistory = await _service.getUserVisitHistory();
      
      // Filter out visits to user's own properties
      if (_currentUser != null) {
        // Uncomment and implement filtering
        _userVisitHistory = _userVisitHistory
            .where((v) => v.ownerId == null || v.ownerId != _currentUser!.id)
            .toList();
        debugPrint("Filtering visits: Current user ID: ${_currentUser!.id}");
        debugPrint("Number of visits after filtering: ${_userVisitHistory.length}");
      } else {
        debugPrint("Current user is null, can't filter own properties");
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Fetch property visit history
  Future<void> fetchPropertyVisitHistory(String propertyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _propertyVisitHistory = await _service.getPropertyVisitHistory(propertyId);
      debugPrint("Got ${_propertyVisitHistory.length} property visits");
      
      // Get all possible user IDs to load
      Set<String> userIdsToLoad = {};
      
      for (var visit in _propertyVisitHistory) {
        // Try to get visitor ID from multiple sources
        if (visit.visitorId != null && visit.visitorId!.isNotEmpty) {
          userIdsToLoad.add(visit.visitorId!);
          debugPrint("Adding visitor ID from visit: ${visit.visitorId}");
        }
        
        // Try to extract from visit ID if needed
        if (visit.id.contains('-') || visit.id.length > 10) {
          try {
            // Try different possible formats
            final parts = visit.id.split('-');
            if (parts.isNotEmpty && parts[0].length >= 6) {
              userIdsToLoad.add(parts[0]);
              debugPrint("Adding ID from visit ID first part: ${parts[0]}");
            }
          } catch (e) {
            debugPrint("Error extracting ID from visit: $e");
          }
        }
      }
      
      debugPrint("Will load ${userIdsToLoad.length} user IDs");
      
      // Load user information
      if (userIdsToLoad.isNotEmpty) {
        _usersCache = await _userService.getUsersCache(userIdsToLoad.toList());
        debugPrint("Loaded ${_usersCache.length} users into cache");
        
        // Debug what was loaded
        _usersCache.forEach((id, info) {
          debugPrint("User $id: ${info.fullName} (${info.email})");
        });
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Error: ${e.toString()}";
      debugPrint("Error loading property history: $e");
      notifyListeners();
    }
  }

  // Fetch filtered visit history
  Future<List<VisitHistory>> fetchFilteredVisitHistory(Map<String, String> filters) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final filteredHistory = await _service.getFilteredVisitHistory(filters);
      _isLoading = false;
      notifyListeners();
      return filteredHistory;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Fetch recommendations based on visit history
  Future<void> fetchRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await _service.getRecommendations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Helper method to get user info by ID
  UserInfo getUserInfo(String userId) {
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId]!;
    }
    
    // Return a placeholder if not found
    return UserInfo(
      id: userId,
      firstName: 'Usuario',
      lastName: userId.substring(0, min(userId.length, 6)),
      email: '',
    );
  }
  
  // Helper function for min
  int min(int a, int b) => a < b ? a : b;
} 