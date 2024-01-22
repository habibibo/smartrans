class CustomerTransaction {
  String? uidUser;
  String? nama;
  String? phone;
  String? email;

  CustomerTransaction({this.uidUser, this.nama, this.phone, this.email});

  CustomerTransaction.fromJson(Map<String, dynamic> json) {
    uidUser = json['uid_user'];
    nama = json['nama'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid_user'] = this.uidUser;
    data['nama'] = this.nama;
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}
