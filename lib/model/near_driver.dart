class NearDriver {
  String? jarakMinimum;
  String? walletMinimum;
  String? id;
  String? namaDriver;
  String? latitude;
  String? longitude;
  String? bearing;
  String? updateAt;
  String? merek;
  String? nomorKendaraan;
  String? warna;
  String? tipe;
  String? saldo;
  String? noTelepon;
  String? foto;
  String? regId;
  String? driverJob;
  String? distance;

  NearDriver(
      {this.jarakMinimum,
      this.walletMinimum,
      this.id,
      this.namaDriver,
      this.latitude,
      this.longitude,
      this.bearing,
      this.updateAt,
      this.merek,
      this.nomorKendaraan,
      this.warna,
      this.tipe,
      this.saldo,
      this.noTelepon,
      this.foto,
      this.regId,
      this.driverJob,
      this.distance});

  NearDriver.fromJson(Map<String, dynamic> json) {
    jarakMinimum = json['jarak_minimum'];
    walletMinimum = json['wallet_minimum'];
    id = json['id'];
    namaDriver = json['nama_driver'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    bearing = json['bearing'];
    updateAt = json['update_at'];
    merek = json['merek'];
    nomorKendaraan = json['nomor_kendaraan'];
    warna = json['warna'];
    tipe = json['tipe'];
    saldo = json['saldo'];
    noTelepon = json['no_telepon'];
    foto = json['foto'];
    regId = json['reg_id'];
    driverJob = json['driver_job'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jarak_minimum'] = this.jarakMinimum;
    data['wallet_minimum'] = this.walletMinimum;
    data['id'] = this.id;
    data['nama_driver'] = this.namaDriver;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['bearing'] = this.bearing;
    data['update_at'] = this.updateAt;
    data['merek'] = this.merek;
    data['nomor_kendaraan'] = this.nomorKendaraan;
    data['warna'] = this.warna;
    data['tipe'] = this.tipe;
    data['saldo'] = this.saldo;
    data['no_telepon'] = this.noTelepon;
    data['foto'] = this.foto;
    data['reg_id'] = this.regId;
    data['driver_job'] = this.driverJob;
    data['distance'] = this.distance;
    return data;
  }
}
