class PricingDetails {
  final String baseFare;
  final String distanceFare;
  final String basicFare;
  final String surgeCharge;
  final String serviceCharge;
  final String extra1;
  final String extra2;
  final String tol;
  final String upping;
  final String charge;
  final String stbd;
  final String maxTawar;
  final String tawar;
  final String fleet;
  final String discount;
  final String tips;
  final String stad;
  final String tax;
  final String price;
  final String minPrice;

  PricingDetails({
    required this.baseFare,
    required this.distanceFare,
    required this.basicFare,
    required this.surgeCharge,
    required this.serviceCharge,
    required this.extra1,
    required this.extra2,
    required this.tol,
    required this.upping,
    required this.charge,
    required this.stbd,
    required this.maxTawar,
    required this.tawar,
    required this.fleet,
    required this.discount,
    required this.tips,
    required this.stad,
    required this.tax,
    required this.price,
    required this.minPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "baseFare": baseFare,
      "distanceFare": distanceFare,
      "basicFare": basicFare,
      "surgeCharge": surgeCharge,
      "serviceCharge": serviceCharge,
      "extra1": extra1,
      "extra2": extra2,
      "tol": tol,
      "upping": upping,
      "charge": charge,
      "stbd": stbd,
      "maxTawar": maxTawar,
      "tawar": tawar,
      "fleet": fleet,
      "discount": discount,
      "tips": tips,
      "stad": stad,
      "tax": tax,
      "price": price,
      "minPrice": minPrice,
    };
  }

  factory PricingDetails.fromJson(Map<String, dynamic> json) {
    return PricingDetails(
      baseFare: json['basefare'].toString() ?? "",
      distanceFare: json['distancefare'].toString() ?? "",
      basicFare: json['basicfare'].toString() ?? "",
      surgeCharge: json['surgecharge'].toString() ?? "",
      serviceCharge: json['servicecharge'].toString() ?? "",
      extra1: json['extra1'].toString() ?? "",
      extra2: json['extra2'].toString() ?? "",
      tol: json['tol'].toString() ?? "",
      upping: json['upping'].toString() ?? "",
      charge: json['charge'].toString() ?? "",
      stbd: json['stbd'].toString() ?? "",
      maxTawar: json['maxtawar'].toString() ?? "",
      tawar: json['tawar'].toString() ?? "",
      fleet: json['fleet'].toString() ?? "",
      discount: json['discount'].toString() ?? "",
      tips: json['tips'].toString() ?? "",
      stad: json['stad'].toString() ?? "",
      tax: json['tax'].toString() ?? "",
      price: json['price'].toString() ?? "",
      minPrice: json['minprice'].toString() ?? "",
    );
  }
}
