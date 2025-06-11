class Visit {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String ownerId;
  final String interestedUserId;
  final DateTime requestedDateTime;
  final String status;
  final String contactEmail;
  final String contactPhone;

  Visit({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.ownerId,
    required this.interestedUserId,
    required this.requestedDateTime,
    required this.status,
    required this.contactEmail,
    required this.contactPhone,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['idVisitRequest'],
      propertyId: json['idProperty'],
      propertyTitle: json['propertyTitle'] ?? '',
      ownerId: json['idOwnerUser'],
      interestedUserId: json['idInterestedUser'],
      requestedDateTime: DateTime.parse(json['requestedDateTime']),
      status: json['status'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
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
}
