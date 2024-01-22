class KendaraanDriver {
  String? jenis;
  String? merk;
  String? platNo;
  String? fotoKendaraan;
  String? keteranganKendaraan;
  int? job;
  int? status;

  KendaraanDriver(
      {this.jenis,
      this.merk,
      this.platNo,
      this.fotoKendaraan,
      this.keteranganKendaraan,
      this.job,
      this.status});

  KendaraanDriver.fromJson(Map<String, dynamic> json) {
    jenis = json['jenis'];
    merk = json['merk'];
    platNo = json['plat_no'];
    fotoKendaraan = json['foto_kendaraan'];
    keteranganKendaraan = json['keterangan_kendaraan'];
    job = json['job'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jenis'] = this.jenis;
    data['merk'] = this.merk;
    data['plat_no'] = this.platNo;
    data['foto_kendaraan'] = this.fotoKendaraan;
    data['keterangan_kendaraan'] = this.keteranganKendaraan;
    data['job'] = this.job;
    data['status'] = this.status;
    return data;
  }
}
