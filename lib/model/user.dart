class UserModel {
  String? id;
  String? uid;
  String? email;
  String? token;
  String? dataAccount;
  String? rating;
  String? dataDriver;
  String? location;
  String? created;
  String? deposit;
  String? transaction;
  String? point;

  UserModel(
      {this.id,
      this.uid,
      this.email,
      this.token,
      this.dataAccount,
      this.rating,
      this.dataDriver,
      this.location,
      this.created,
      this.deposit,
      this.transaction,
      this.point});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    email = json['email'];
    token = json['token'];
    dataAccount = json['data_account'];
    rating = json['rating'];
    dataDriver = json['data_driver'];
    location = json['location'];
    created = json['created'];
    deposit = json['deposit'];
    transaction = json['transaction'];
    point = json['point'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['email'] = this.email;
    data['token'] = this.token;
    data['data_account'] = this.dataAccount;
    data['rating'] = this.rating;
    data['data_driver'] = this.dataDriver;
    data['location'] = this.location;
    data['created'] = this.created;
    data['deposit'] = this.deposit;
    data['transaction'] = this.transaction;
    data['point'] = this.point;
    return data;
  }
}
