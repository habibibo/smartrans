import 'package:signgoogle/model/driverlatlng.dart';

class DriverBid {
  String? idPassenger;
  String? namaPassenger;
  String? idDriver;
  String? namaDriver;
  String? jarakTujuan;
  String? totalAlamat;
  String? fotoDriver;
  String? ratingDriver;
  String? kendaraan;
  DriverLatLng? driverLatLng;
  String? tarif;
  String? bid;
  String? jarakDriver;
  String? waktuJemput;
  String? pembayaran;

  DriverBid(
      {this.idPassenger,
      this.namaPassenger,
      this.idDriver,
      this.namaDriver,
      this.jarakTujuan,
      this.totalAlamat,
      this.fotoDriver,
      this.ratingDriver,
      this.kendaraan,
      required this.driverLatLng,
      this.tarif,
      this.bid,
      this.jarakDriver,
      this.waktuJemput,
      this.pembayaran});

  DriverBid.fromJson(Map<String, dynamic> json) {
    idPassenger = json['id_passenger'];
    namaPassenger = json['nama_passenger'];
    idDriver = json['id_driver'];
    namaDriver = json['nama_driver'];
    jarakTujuan = json['jarak_tujuan'];
    totalAlamat = json['total_alamat'];
    fotoDriver = json['foto_driver'];
    ratingDriver = json['rating_driver'];
    kendaraan = json['kendaraan'];
    driverLatLng = json['driverLatLng'];
    tarif = json['tarif'];
    bid = json['bid'];
    jarakDriver = json['jarak_driver'];
    waktuJemput = json['waktu_jemput'];
    pembayaran = json['pembayaran'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_passenger'] = this.idPassenger;
    data['nama_passenger'] = this.namaPassenger;
    data['id_driver'] = this.idDriver;
    data['nama_driver'] = this.namaDriver;
    data['jarak_tujuan'] = this.jarakTujuan;
    data['total_alamat'] = this.totalAlamat;
    data['foto_driver'] = this.fotoDriver;
    data['rating_driver'] = this.ratingDriver;
    data['kendaraan'] = this.kendaraan;
    data['driverLatLng'] = this.driverLatLng;
    data['tarif'] = this.tarif;
    data['bid'] = this.bid;
    data['jarak_driver'] = this.jarakDriver;
    data['waktu_jemput'] = this.waktuJemput;
    data['pembayaran'] = this.pembayaran;
    return data;
  }
}
