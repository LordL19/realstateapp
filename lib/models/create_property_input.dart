class CreatePropertyInput {
  final String title;
  final String description;
  final String address;
  final String city;
  final String country;
  final String propertyType;
  final String transactionType;
  final double price;
  final int area;
  final int builtArea;
  final int bedrooms;
  final List<String> photos;

  CreatePropertyInput({
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.propertyType,
    required this.transactionType,
    required this.price,
    required this.area,
    required this.builtArea,
    required this.bedrooms,
    required this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'propertyType': propertyType,
      'transactionType': transactionType,
      'price': price,
      'area': area,
      'builtArea': builtArea,
      'bedrooms': bedrooms,
      'photos': photos,
    };
  }
} 