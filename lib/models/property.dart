import 'create_property_input.dart';

class Property {
  final String idProperty;
  final String idUser;
  final String title;
  final String? description;
  final String? address;
  final String city;
  final String country;
  final String? propertyType;
  final String? transactionType;
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
    this.description,
    this.address,
    required this.city,
    required this.country,
    this.propertyType,
    this.transactionType,
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

  Property copyWith(CreatePropertyInput input) {
    return Property(
      idProperty: idProperty,
      idUser: idUser,
      title: input.title,
      description: input.description,
      address: input.address,
      city: input.city,
      country: input.country,
      propertyType: input.propertyType,
      transactionType: input.transactionType,
      status: status,
      price: input.price,
      area: input.area,
      builtArea: input.builtArea,
      bedrooms: input.bedrooms,
      photos: input.photos,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Property mergeWith(Property other) {
    return Property(
      idProperty: idProperty,
      idUser: idUser,
      title: other.title,
      description: description ?? other.description,
      address: address ?? other.address,
      city: other.city,
      country: other.country,
      propertyType: propertyType ?? other.propertyType,
      transactionType: transactionType ?? other.transactionType,
      status: other.status,
      price: other.price,
      area: other.area,
      builtArea: other.builtArea,
      bedrooms: other.bedrooms,
      photos: other.photos,
      createdAt: createdAt,
      updatedAt: other.updatedAt,
    );
  }
} 