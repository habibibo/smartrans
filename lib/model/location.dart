class Location {
  final String lat;
  final String lng;
  final String address;
  //final int minPrice;

  Location({
    required this.address,
    required this.lat,
    required this.lng,
    //required this.minPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
