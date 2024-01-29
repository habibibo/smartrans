class Location {
  final String address;
  final String lat;
  final String lng;
  //final int minPrice;

  Location({
    required this.address,
    required this.lat,
    required this.lng,
    //required this.minPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] ?? '',
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
    );
  }
}
