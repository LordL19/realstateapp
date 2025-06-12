class UserProfile {
  final String idUser;
  final String email;
  final String firstName;
  final String lastName;
  final String city;
  final String country;

  const UserProfile({
    required this.idUser,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      idUser: json['idUser'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'country': country,
    };
  }
}
