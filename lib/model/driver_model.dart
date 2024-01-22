import 'package:flutter_map_directions/flutter_map_directions.dart';

class DriverModel {
  int id;
  String name;
  String photoUrl;
  int price;
  List<LatLng> latlng;
  String car;
  String nopol;
  String distanceOrder;
  String distanceDriver;
  String arriveTime;

  DriverModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.price,
    required this.latlng,
    required this.car,
    required this.nopol,
    required this.distanceOrder,
    required this.distanceDriver,
    required this.arriveTime,
  });

  /* factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      name: json['fitur'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      price: json['price'] ?? 0,
      minPrice: json['minprice'] ?? 0,
    );
  } */
}
