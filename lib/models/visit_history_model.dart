class VisitHistory {
  final String id;
  final String idProperty;
  final String propertyTitle;
  final String propertyType;
  final String transactionType;
  final String city;
  final String country;
  final DateTime visitDate;
  final String? visitorId;
  final String? ownerId;

  VisitHistory({
    required this.id,
    required this.idProperty,
    required this.propertyTitle,
    required this.propertyType,
    required this.transactionType,
    required this.city,
    required this.country,
    required this.visitDate,
    this.visitorId,
    this.ownerId,
  });

  factory VisitHistory.fromJson(Map<String, dynamic> json) {
    // Extract the owner ID with more priority options
    String? ownerId;
    if (json.containsKey('ownerId') && json['ownerId'] != null) {
      ownerId = json['ownerId'].toString();
    } else if (json.containsKey('idOwnerUser') && json['idOwnerUser'] != null) {
      ownerId = json['idOwnerUser'].toString();
    } else if (json.containsKey('idUser') && json['idUser'] != null) {
      ownerId = json['idUser'].toString();
    }
    
    return VisitHistory(
      id: json['id'] ?? '',
      idProperty: json['idProperty'] ?? '',
      propertyTitle: json['propertyTitle'] ?? 'Sin título',
      propertyType: json['propertyType'] ?? 'No especificado',
      transactionType: json['transactionType'] ?? 'No especificado',
      city: json['city'] ?? 'No especificado',
      country: json['country'] ?? 'No especificado',
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : DateTime.now(),
      visitorId: json['visitorId'] ?? json['userId'],
      ownerId: ownerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idProperty': idProperty,
      'propertyTitle': propertyTitle,
      'propertyType': propertyType,
      'transactionType': transactionType,
      'city': city,
      'country': country,
      'visitDate': visitDate.toIso8601String(),
      'visitorId': visitorId,
      'ownerId': ownerId,
    };
  }
} 