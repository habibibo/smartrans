import 'pricing_detail.dart';

class Feature {
  final int id;
  final String name;
  final String iconUrl;
  final PricingDetails price;
  //final int minPrice;

  Feature({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.price,
    //required this.minPrice,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id_fitur'] ?? 0,
      name: json['fitur'] ?? '',
      iconUrl: json['icon_fitur'] ?? '',
      //price: json['price'] ?? '',
      price: PricingDetails.fromJson(json['price'] ?? {}),
      //minPrice: json['minprice'] ?? 0,
    );
  }
}
