class Property {
  final String idProperty;
  final String idUser;
  final String title;
  final String description;
  final String address;
  final String city;
  final String country;
  final String propertyType;
  final String transactionType;
  final String status;
  final double price;
  final int area;
  final int builtArea;
  final int bedrooms;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.idProperty,
    required this.idUser,
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.propertyType,
    required this.transactionType,
    required this.status,
    required this.price,
    required this.area,
    required this.builtArea,
    required this.bedrooms,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      idProperty: json['idProperty'],
      idUser: json['idUser'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      propertyType: json['propertyType'],
      transactionType: json['transactionType'],
      status: json['status'],
      price: (json['price'] as num).toDouble(),
      area: json['area'],
      builtArea: json['builtArea'],
      bedrooms: json['bedrooms'],
      photos: List<String>.from(json['photos']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 