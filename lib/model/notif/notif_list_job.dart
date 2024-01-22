class NotifListJob {
  final String uid_user;
  final String nama_user;
  final String distance;
  final String total_alamat;
  final String tarif;
  //final String bid;
  final String jarak_driver;
  final String waktu_jemput;
  final String pembayaran;
  final String waktu_pickup;
  //final String jam;
  final bool isOpen;
  final String token_user;

  NotifListJob(
      {required this.uid_user,
      required this.nama_user,
      required this.distance,
      required this.total_alamat,
      required this.tarif,
      //required this.bid,
      required this.jarak_driver,
      required this.waktu_jemput,
      required this.pembayaran,
      required this.waktu_pickup,
      //required this.jam,
      required this.isOpen,
      required this.token_user});

  // Convert Car object to Map
  Map<String, dynamic> toJson() => {
        'uid_user': uid_user,
        'nama_user': nama_user,
        'distance': distance,
        'total_alamat': total_alamat,
        'tarif': tarif,
        // 'bid': bid,
        'jarak_driver': jarak_driver,
        'waktu_jemput': waktu_jemput,
        'pembayaran': pembayaran,
        'waktu_pickup': waktu_pickup,
        //'jam': jam,
        'isOpen': isOpen,
        'token_user': token_user
      };

  // Create Car object from Map
  factory NotifListJob.fromJson(Map<String, dynamic> json) => NotifListJob(
        uid_user: json['uid_user'],
        nama_user: json['nama_user'],
        distance: json['distance'],
        total_alamat: json['total_alamat'],
        tarif: json['tarif'],
        //  bid: json['bid'],
        jarak_driver: json['jarak_driver'],
        waktu_jemput: json['waktu_jemput'],
        pembayaran: json['pembayaran'],
        waktu_pickup: json['waktu_pickup'],
        //jam: json['jam'],
        isOpen: json['isOpen'],
        token_user: json['token_user'],
      );
}
