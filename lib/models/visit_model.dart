class Visit {
  final String id;
  final String propertyId;
  final String ownerId;
  final String interestedUserId;
  final DateTime requestedDateTime;
  final String status;
  final String contactEmail;
  final String contactPhone;
  final String? propertyTitle; // Opcional, se asigna después

  Visit({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.interestedUserId,
    required this.requestedDateTime,
    required this.status,
    required this.contactEmail,
    required this.contactPhone,
    this.propertyTitle,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['idVisitRequest'],
      propertyId: json['idProperty'],
      ownerId: json['idOwnerUser'],
      interestedUserId: json['idInterestedUser'],
      requestedDateTime: DateTime.parse(json['requestedDateTime']),
      status: json['status'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      propertyTitle: json['propertyTitle'], // puede ser null o no venir
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idProperty": propertyId,
      "idOwnerUser": ownerId,
      "requestedDateTime": requestedDateTime.toIso8601String(),
      "contactEmail": contactEmail,
      "contactPhone": contactPhone,
    };
  }

  Visit copyWithTitle(String title) {
    return Visit(
      id: id,
      propertyId: propertyId,
      ownerId: ownerId,
      interestedUserId: interestedUserId,
      requestedDateTime: requestedDateTime,
      status: status,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      propertyTitle: title,
    );
  }
}
