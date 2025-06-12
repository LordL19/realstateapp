class CreateVisitHistoryRequest {
  final String idProperty;
  final String propertyTitle;
  final String propertyType;
  final String transactionType;
  final String city;
  final String country;
  final String? ownerId;

  CreateVisitHistoryRequest({
    required this.idProperty,
    required this.propertyTitle,
    required this.propertyType,
    required this.transactionType,
    required this.city,
    required this.country,
    this.ownerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'idProperty': idProperty,
      'propertyTitle': propertyTitle,
      'propertyType': propertyType,
      'transactionType': transactionType,
      'city': city,
      'country': country,
      'ownerId': ownerId,
    };
  }
} 