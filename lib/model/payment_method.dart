class PaymentMethod {
  int? idPaymentmethod;
  String? paymentmethod;
  String? icon;
  String? imageQr;
  String? total;

  PaymentMethod(
      {this.idPaymentmethod,
      this.paymentmethod,
      this.icon,
      this.imageQr,
      this.total});

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    idPaymentmethod = json['id_paymentmethod'];
    paymentmethod = json['paymentmethod'];
    icon = json['icon'];
    imageQr = json['image_qr'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_paymentmethod'] = this.idPaymentmethod;
    data['paymentmethod'] = this.paymentmethod;
    data['icon'] = this.icon;
    data['image_qr'] = this.imageQr;
    data['total'] = this.total;
    return data;
  }
}
