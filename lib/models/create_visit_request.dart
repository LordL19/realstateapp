class CreateVisitRequest {
  final String idProperty;
  final String idOwnerUser;
  final DateTime requestedDateTime;
  final String contactPhone;
  final String contactEmail;

  CreateVisitRequest({
    required this.idProperty,
    required this.idOwnerUser,
    required this.requestedDateTime,
    required this.contactPhone,
    required this.contactEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'idProperty': idProperty,
      'idOwnerUser': idOwnerUser,
      'requestedDateTime': requestedDateTime.toUtc().toIso8601String(),
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
  }
}
