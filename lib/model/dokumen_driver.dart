class DokumenDriver {
  String? nid;
  String? jenisDokumen;
  String? fotoDokumen;
  String? datevalid;
  String? keteranganDokumen;
  int? status;

  DokumenDriver(
      {this.nid,
      this.jenisDokumen,
      this.fotoDokumen,
      this.datevalid,
      this.keteranganDokumen,
      this.status});

  DokumenDriver.fromJson(Map<String, dynamic> json) {
    nid = json['nid'];
    jenisDokumen = json['jenis_dokumen'];
    fotoDokumen = json['foto_dokumen'];
    datevalid = json['datevalid'];
    keteranganDokumen = json['keterangan_dokumen'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nid'] = this.nid;
    data['jenis_dokumen'] = this.jenisDokumen;
    data['foto_dokumen'] = this.fotoDokumen;
    data['datevalid'] = this.datevalid;
    data['keterangan_dokumen'] = this.keteranganDokumen;
    data['status'] = this.status;
    return data;
  }
}
