import 'package:flutter_map_directions/flutter_map_directions.dart';

class RouteTransaction {
  String? durasi;
  String? distance;
  String? trafficTime;
  List<LatLng>? location;

  RouteTransaction(
      {this.durasi, this.distance, this.trafficTime, this.location});

  RouteTransaction.fromJson(Map<String, dynamic> json) {
    durasi = json['durasi'];
    distance = json['distance'];
    trafficTime = json['trafficTime'];
    location = json['location'];
    /* if (json['location'] != null) {
      location = <LatLng>[];
      json['location'].forEach((v) {
        location!.add(new LatLng.fromJson(v));
      });
    } */
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['durasi'] = this.durasi;
    data['distance'] = this.distance;
    data['trafficTime'] = this.trafficTime;
    data['location'] = this.location;
    /* if (this.location != null) {
      data['location'] = this.location!.map((v) => v.toJson()).toList();
    } */
    return data;
  }
}
