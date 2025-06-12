class UserInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
} 