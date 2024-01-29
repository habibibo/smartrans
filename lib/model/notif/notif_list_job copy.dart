class NotifListJob {
  final String id_passenger;
  final String nama_passenger;
  final String jarak_tujuan;
  final String total_alamat;
  final String tarif;
  final String bid;
  final String jarak_driver;
  final String waktu_jemput;
  final String pembayaran;
  final String waktu_pickup;
  final String id_driver;
  final String nama_driver;
  final String foto_driver;
  final String kendaraan;
  final String rating_driver;
  final String token_user;

  NotifListJob(
      {required this.id_passenger,
      required this.nama_passenger,
      required this.jarak_tujuan,
      required this.total_alamat,
      required this.tarif,
      required this.bid,
      required this.jarak_driver,
      required this.waktu_jemput,
      required this.pembayaran,
      required this.waktu_pickup,
      required this.id_driver,
      required this.nama_driver,
      required this.foto_driver,
      required this.kendaraan,
      required this.rating_driver,
      required this.token_user});

  // Convert Car object to Map
  Map<String, dynamic> toJson() => {
        'id_passenger': id_passenger,
        'nama_passenger': nama_passenger,
        'jarak_tujuan': jarak_tujuan,
        'total_alamat': total_alamat,
        'tarif': tarif,
        'bid': bid,
        'jarak_driver': jarak_driver,
        'waktu_jemput': waktu_jemput,
        'pembayaran': pembayaran,
        'waktu_pickup': waktu_pickup,
        'id_driver': id_driver,
        'nama_driver': nama_driver,
        'foto_driver': foto_driver,
        'kendaraan': kendaraan,
        'rating_driver': rating_driver,
        'token_user': token_user
      };

  // Create Car object from Map
  factory NotifListJob.fromJson(Map<String, dynamic> json) => NotifListJob(
        id_passenger: json['id_passenger'].toString(),
        nama_passenger: json['nama_passenger'].toString(),
        jarak_tujuan: json['jarak_tujuan'].toString(),
        total_alamat: json['total_alamat'].toString(),
        tarif: json['tarif'].toString(),
        bid: json['bid'].toString(),
        jarak_driver: json['jarak_driver'].toString(),
        waktu_jemput: json['waktu_jemput'].toString(),
        pembayaran: json['pembayaran'].toString(),
        waktu_pickup: json['waktu_pickup'].toString(),
        id_driver: json['id_driver'].toString(),
        foto_driver: json['foto_driver'].toString(),
        nama_driver: json['nama_driver'].toString(),
        kendaraan: json['kendaraan'].toString(),
        rating_driver: json['rating_driver'].toString(),
        token_user: json['token_user'].toString(),
      );
}
