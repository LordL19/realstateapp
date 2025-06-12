import 'package:latlong2/latlong.dart';

class ReviewData {
  final String title, desc;
  final String? type, txn, country, city, address;
  final double? price;
  final int? area, built, beds;
  final List<String> photos;
  final LatLng? latLng;

  ReviewData({
    required this.title,
    required this.desc,
    required this.type,
    required this.txn,
    required this.country,
    required this.city,
    required this.address,
    required this.price,
    required this.area,
    required this.built,
    required this.beds,
    required this.photos,
    this.latLng,
  });
}
