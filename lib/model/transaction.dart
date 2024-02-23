class Transaction {
  String? uid;
  String? nowlater;
  String? waktuPickup;
  String? notes;
  String? addons;
  String? idFitur;
  String? fitur;
  String? pax;
  String? qty;
  String? area;
  String? paymentmethod;
  String? promo;
  String? geofence;

  Transaction(
      {this.uid,
      this.nowlater,
      this.waktuPickup,
      this.notes,
      this.addons,
      this.idFitur,
      this.fitur,
      this.pax,
      this.qty,
      this.area,
      this.paymentmethod,
      this.promo,
      this.geofence});

  Transaction.fromJson(Map<String, dynamic> json) {
    uid = json['uid'].toString();
    nowlater = json['nowlater'].toString();
    waktuPickup = json['waktu_pickup'].toString();
    notes = json['notes'].toString();
    addons = json['addons'].toString();
    idFitur = json['id_fitur'].toString();
    fitur = json['fitur'].toString();
    pax = json['pax'].toString();
    qty = json['qty'].toString();
    area = json['area'].toString();
    paymentmethod = json['paymentmethod'].toString();
    promo = json['promo'].toString();
    geofence = json['geofence'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['nowlater'] = this.nowlater;
    data['waktu_pickup'] = this.waktuPickup;
    data['notes'] = this.notes;
    data['addons'] = this.addons;
    data['id_fitur'] = this.idFitur;
    data['fitur'] = this.fitur;
    data['pax'] = this.pax;
    data['qty'] = this.qty;
    data['area'] = this.area;
    data['paymentmethod'] = this.paymentmethod;
    data['promo'] = this.promo;
    data['geofence'] = this.geofence;
    return data;
  }
}
