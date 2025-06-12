import 'package:flutter/material.dart';
import 'package:realestate_app/models/create_visit_request.dart';
import '../models/visit_model.dart';
import '../services/visit_service.dart';

class VisitViewModel extends ChangeNotifier {
  final VisitService _visitService = VisitService();

  List<Visit> myVisits = [];
  List<Visit> ownerVisits = [];
  List<Visit> propertyVisits = [];

  bool isLoading = false;
  String? errorMessage;

  // Cargar visitas del usuario interesado
  Future<void> fetchMyVisits() async {
    isLoading = true;
    notifyListeners();

    try {
      myVisits = await _visitService.getMyVisits();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Cargar visitas como propietario
  Future<void> fetchOwnerVisits() async {
    isLoading = true;
    notifyListeners();

    try {
      ownerVisits = await _visitService.getVisitsByOwner();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Cargar visitas para una propiedad específica
  Future<void> fetchPropertyVisits(String propertyId) async {
    isLoading = true;
    notifyListeners();

    try {
      propertyVisits = await _visitService.getVisitsByProperty(propertyId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Crear una nueva visita
  Future<bool> createVisit(CreateVisitRequest visit) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _visitService.createVisit(visit);
      return true;
    } catch (e) {
      final message = e.toString().toLowerCase();
      debugPrint(message);
      if (message.contains('exception') || message.contains('existe')) {
        errorMessage = 'Ya hay una visita agendada en ese horario.';
      } else {
        errorMessage = 'Error al agendar la visita. Inténtalo de nuevo.';
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar el estado de una visita (aceptar, rechazar, etc.)
  Future<bool> updateVisitStatus(
      String idVisitRequest, String newStatus) async {
    try {
      await _visitService.updateStatus(idVisitRequest, newStatus);
      await fetchOwnerVisits(); // recargar lista
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelVisit(String idVisitRequest) async {
    try {
      await _visitService.cancelVisit(idVisitRequest);
      await fetchMyVisits(); // Recargar visitas del interesado
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
