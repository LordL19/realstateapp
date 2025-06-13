class UserProfile {
  final String idUser;
  final String email;
  final String firstName;
  final String lastName;
  final String city;
  final String country;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;

  const UserProfile({
    required this.idUser,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      idUser: json['idUser'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
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
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }
}
