import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:mime/mime.dart';
import 'package:phonecodes/phonecodes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/dokumen_driver.dart';
import 'package:signgoogle/model/kendaraan_driver.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/screen/driver/home.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:http/http.dart' as http;
import 'package:tab_container/tab_container.dart';

class BerkasDriver extends StatefulWidget {
  //GoogleSignInAccount? user;
  UserModel userModel;
  BerkasDriver({Key? key, required this.userModel}) : super(key: key);

  @override
  State<BerkasDriver> createState() => _BerkasDriverState();
}

class SelectOption {
  final String label;
  final String value;

  SelectOption({required this.label, required this.value});
}

class _BerkasDriverState extends State<BerkasDriver> {
  TextEditingController dateBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String countryCode = "";
  String foto_akun = "";
  TextEditingController nidController = TextEditingController();
  TextEditingController jenis_dokumenController = TextEditingController();
  TextEditingController datevalidController = TextEditingController();
  TextEditingController keterangan_dokumenController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController uploadImageController = TextEditingController();

  TextEditingController jenisController = TextEditingController();
  TextEditingController merkController = TextEditingController();
  TextEditingController platNoController = TextEditingController();
  TextEditingController fotoKendaraanController = TextEditingController();
  TextEditingController keteranganKendaraanController = TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController uploadKendaraanController = TextEditingController();

  List<File> newFileDokumen = [];
  List<File> newFileKendaraan = [];

  String responseImage = "";
  final List<SelectOption> utilityDriver = [
    SelectOption(label: 'Dokumen Driver', value: 'dokumen_driver'),
    SelectOption(label: 'Kendaraan Driver', value: 'kendaraan_driver'),
  ];
  final List<SelectOption> categoryDocuments = [
    SelectOption(label: 'KTP', value: 'KTP'),
    SelectOption(label: 'SIM A', value: 'SIM A'),
    SelectOption(label: 'SIM B', value: 'SIM B'),
    SelectOption(label: 'SIM C', value: 'SIM C'),
  ];

  SelectOption? selectedOption;
  SelectOption? categoryDocument;
  bool showAddDokumenDriver = true;
  bool showAddKendaraanDriver = false;
  List<DokumenDriver> newListDokumenDriver = [];
  List<KendaraanDriver> newListKendaraanDriver = [];

  bool loadingButtonDoc = true;
  bool loadingButtonVehicle = true;

  @override
  void initState() {
    super.initState();
    var jsonUserModel = jsonEncode(widget.userModel.toJson());
    print(jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
        ["countrycode"]);

    dateBirthController.text =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["tanggal_lahir"];
    countryCode = jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
        ["countrycode"];
    print(Countries.findByDialCode("${countryCode}").first.flag);
    phoneController.text =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
            ["phoneno"];
    foto_akun =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
    //print(jsonDecode(widget.userModel.dataAccount.toString())["phone"]
    //    ["phoneno"]);
    jenis_dokumenController.text = categoryDocuments[0].value;
    print(jsonDecode(jsonUserModel)["data_driver"]);
  }

  late File _image;
  late File _image2;
  final picker = ImagePicker();
  Future getImage() async {
    _image = File("");
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImageController.text = pickedFile.name;
        print(pickedFile.name);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImage2() async {
    _image2 = File("");
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image2 = File(pickedFile.path);
        uploadKendaraanController.text = pickedFile.name;
        print(pickedFile.name);
      } else {
        print('No image selected.');
      }
    });
  }

  void saveDataDriver() {
    print(widget.userModel.dataDriver);
    if (widget.userModel.dataDriver == null) {
      for (int i = 0; i <= newFileDokumen.length - 1; i++) {
        uploadBerkas(newFileDokumen[i], "dokumen", i);
        //Future.delayed(Duration(seconds: 1));
        if (i == newFileDokumen.length - 1) {
          for (int i2 = 0; i2 <= newFileKendaraan.length - 1; i2++) {
            uploadBerkas(newFileKendaraan[i2], "kendaraan", i2);
            //Future.delayed(Duration(seconds: 1));
          }
        }
      }

      print(jsonEncode(newListDokumenDriver));
    } else {}
  }

  Future<void> uploadBerkas(File berkas, String type, int index) async {
    String addimageUrl = 'https://asset.smartrans.id/upload_image.php';
    Map<String, String> headers = {
      'Authorization': "Basic YmFzZTY0OmVtYWls",
      'Content-type': 'multipart/form-data',
    };
    var request = http.MultipartRequest('POST', Uri.parse(addimageUrl));
    request.headers.addAll(headers);
    String? mimeType = lookupMimeType(berkas.path);
    var multipartFile = http.MultipartFile(
      'image', // The name of the field for the file
      http.ByteStream.fromBytes(berkas.readAsBytesSync()),
      berkas.lengthSync(),
      filename: 'image_file.jpg',
      contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    var streamREesponse = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      if (type == "dokumen") {
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          print("dokumen");
          newListDokumenDriver[index].fotoDokumen =
              jsonDecode(streamREesponse.body)["filename"];
          print(newListDokumenDriver[index].fotoDokumen);
        });
      }
      if (type == "kendaraan") {
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          print("kendaraan");
          newListKendaraanDriver[index].fotoKendaraan =
              jsonDecode(streamREesponse.body)["filename"];
          print(newListKendaraanDriver[index].fotoKendaraan);
        });
        if (index == newFileKendaraan.length - 1) {
          final dataDriver = {
            "keterangan_driver": "Menunggu Aktivasi",
            "status_driver": 0,
            "dokumen_driver": jsonEncode(newListDokumenDriver),
            "kendaraan_driver": jsonEncode(newListKendaraanDriver)
          };
          final userData = {
            "id": widget.userModel.id,
            "uid": widget.userModel.uid,
            "email": widget.userModel.email,
            "token": widget.userModel.token,
            "data_account": widget.userModel.dataAccount,
            "rating": widget.userModel.rating,
            "data_driver": jsonEncode(dataDriver),
            "location": widget.userModel.location,
            "created": widget.userModel.created,
            "deposit": widget.userModel.deposit,
            "transaction": widget.userModel.transaction,
            "point": widget.userModel.point
          };
          setState(() {
            widget.userModel.dataDriver = jsonEncode(dataDriver);
          });
          //updateUserCache(userData.toString());
          LoginRepo().updateUser(userData);
        }
      }
    } else {
      print("error");
    }
  }

  Future updloadFiles(File berkas, String type) async {
    String addimageUrl = 'https://asset.smartrans.id/upload_image.php';
    Map<String, String> headers = {
      'Authorization': "Basic YmFzZTY0OmVtYWls",
      'Content-type': 'multipart/form-data',
    };
    var request = http.MultipartRequest('POST', Uri.parse(addimageUrl));
    request.headers.addAll(headers);
    String? mimeType = lookupMimeType(berkas.path);
    var multipartFile = http.MultipartFile(
      'image', // The name of the field for the file
      http.ByteStream.fromBytes(berkas.readAsBytesSync()),
      berkas.lengthSync(),
      filename: 'image_file.jpg',
      contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    var streamREesponse = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      if (type == "dokumen") {
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          loadingButtonDoc = true;
          print("dokumen");
          newListDokumenDriver.add(DokumenDriver(
              nid: nidController.text,
              jenisDokumen: jenis_dokumenController.text,
              fotoDokumen: jsonDecode(streamREesponse.body)["filename"],
              datevalid: datevalidController.text,
              keteranganDokumen: "On Review",
              status: 0));
          newFileDokumen.add(_image);
        });
      }
      if (type == "kendaraan") {
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          loadingButtonVehicle = true;
          print("kendaraan");
          newListKendaraanDriver.add(KendaraanDriver(
              jenis: jenisController.text,
              merk: merkController.text,
              platNo: platNoController.text,
              fotoKendaraan: jsonDecode(streamREesponse.body)["filename"],
              keteranganKendaraan: "On Review",
              status: 0));
          newFileKendaraan.add(_image2);
          /* newListKendaraanDriver[index].fotoKendaraan =
              jsonDecode(streamREesponse.body)["filename"];
          print(newListKendaraanDriver[index].fotoKendaraan); */
        });
      }
    }
  }

  void updateUser() {
    final dataDriver = {
      "keterangan_driver": "Menunggu Aktivasi",
      "status_driver": 0,
      "dokumen_driver": jsonEncode(newListDokumenDriver),
      "kendaraan_driver": jsonEncode(newListKendaraanDriver)
    };
    final userData = {
      "id": widget.userModel.id,
      "uid": widget.userModel.uid,
      "email": widget.userModel.email,
      "token": widget.userModel.token,
      "data_account": widget.userModel.dataAccount,
      "rating": widget.userModel.rating,
      "data_driver": jsonEncode(dataDriver),
      "location": widget.userModel.location,
      "created": widget.userModel.created,
      "deposit": widget.userModel.deposit,
      "transaction": widget.userModel.transaction,
      "point": widget.userModel.point
    };
    setState(() {
      widget.userModel.dataDriver = jsonEncode(dataDriver);
    });
    LoginRepo().updateUser(userData).then((value) {
      print(value);
      if (value["status"] == "ok") {
        Navigator.of(context, rootNavigator: true).pop();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: value["message"],
            autoCloseDuration: Duration(seconds: 2));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DriverHome(userModel: widget.userModel, isDriver: true)));
      } else {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            text: value["message"],
            autoCloseDuration: Duration(seconds: 2));
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void updateUserCache(String userData) async {
    SharedPreferences userCache = await SharedPreferences.getInstance();
    setState(() {
      userCache.setString("userModel", userData);
    });
  }

  void deleteDataDriver(int index, String type) {
    if (type == "kendaraan") {
      setState(() {
        newListKendaraanDriver.remove(newListKendaraanDriver[index]);
        print(newListKendaraanDriver.length);
      });
    } else {
      setState(() {
        newListDokumenDriver.remove(newListDokumenDriver[index]);
        print(newListDokumenDriver.length);
      });
    }
  }

  Widget buildDokumenDriverForm() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(90),
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(120),
          ),
          color: Colors.white),
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.assignment_ind),
                    ),
                    Container(
                      height: 50,
                      width: 150,
                      child: SelectFormField(
                        type: SelectFormFieldType.dropdown, // or can be dialog
                        initialValue: 'KTP',
                        labelText: 'Dokumen',
                        items: [
                          {
                            'value': 'KTP',
                            'label': 'KTP',
                          },
                          {
                            'value': 'SIM A',
                            'label': 'SIM A',
                          },
                          {
                            'value': 'SIM B',
                            'label': 'SIM B',
                          },
                          {
                            'value': 'SIM C',
                            'label': 'SIM C',
                          },
                        ],
                        onChanged: (val) => jenis_dokumenController.text = val,
                      ),
                    ),
                  ],
                )),
            Container(
              child: TextField(
                scrollPhysics: ScrollPhysics().parent,
                controller: nidController,
                decoration: InputDecoration(
                  icon: Icon(Icons.contacts_outlined),
                  labelText: "No ID",
                ),
              ),
            ),
            Container(
              child: TextField(
                readOnly: true,
                controller: uploadImageController,
                decoration: InputDecoration(
                  icon: Icon(Icons.image),
                  labelText: "Upload foto dokumen",
                ),
                onTap: () => getImage(),
              ),
            ),
            Container(
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_month_outlined),
                  labelText: "Tanggal berlaku",
                ),
                controller: datevalidController,
                readOnly: true,
                onTap: () async {
                  DateTime? dateTime = await showDatePicker(
                      onDatePickerModeChange: (value) {
                        setState(() {
                          datevalidController.text = value.toString();
                        });
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2100));
                  print(dateTime);
                  if (dateTime != null) {
                    //print(dateTime);
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                    print(formattedDate);
                    setState(() {
                      datevalidController.text = formattedDate;
                    });
                  }
                },
              ),
            ),
            Text(responseImage),
            Container(
              child: loadingButtonDoc == true
                  ? MaterialButton(
                      shape: StadiumBorder(),
                      color: Colors.blue,
                      child: Text("Tambah"),
                      onPressed: () async {
                        print("Tambah dokumen");
                        if (nidController.text.isEmpty ||
                            uploadImageController.text.isEmpty ||
                            dateBirthController.text.isEmpty) {
                          QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              text: "Harap lengkapi field");
                        } else {
                          if (jenis_dokumenController.text.isEmpty) {
                            jenis_dokumenController.text = "KTP";
                          }
                          if (newListDokumenDriver
                              .where((element) =>
                                  element.jenisDokumen.toString() ==
                                  jenis_dokumenController.text)
                              .isEmpty) {
                            setState(() {
                              loadingButtonDoc = false;
                            });

                            updloadFiles(_image, "dokumen");
                          } else {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                text: "Jenis dokumen pernah ditambahkan");
                          }
                        }

                        /* setState(() {
                      newListDokumenDriver.add(DokumenDriver(
                          nid: nidController.text,
                          jenisDokumen: jenis_dokumenController.text,
                          fotoDokumen: uploadImageController.text,
                          datevalid: datevalidController.text,
                          keteranganDokumen: "On Review",
                          status: 0));
                      newFileDokumen.add(_image);
                    }); */
                      })
                  : Center(
                      child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: CircularProgressIndicator())),
            ),
            newListDokumenDriver.length == 0 ? Container() : listDokumenDriver()
          ],
        ),
      ),
    );
  }

  Widget buildKendaraanDriverForm() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(90),
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(120),
          ),
          color: Colors.white),
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: TextField(
              controller: jenisController,
              decoration: InputDecoration(
                labelText: "Jenis (Avanza / Mobilio, etc)",
                icon: Icon(Icons.directions_car_filled_outlined),
              ),
            )),
            Container(
              child: TextField(
                controller: merkController,
                decoration: InputDecoration(
                  icon: Icon(Icons.directions_car_filled_outlined),
                  labelText: "Merk (Toyota / Honda / Daihatsu, etc)",
                ),
              ),
            ),
            Container(
              child: TextField(
                controller: platNoController,
                decoration: InputDecoration(
                  icon: Icon(Icons.directions_car_filled_outlined),
                  labelText: "Plat Nomor",
                ),
              ),
            ),
            Container(
              child: TextField(
                readOnly: true,
                controller: uploadKendaraanController,
                decoration: InputDecoration(
                  icon: Icon(Icons.image),
                  labelText: "Upload foto kendaraan",
                ),
                onTap: () => getImage2(),
              ),
            ),
            Container(
              child: loadingButtonVehicle == true
                  ? MaterialButton(
                      shape: StadiumBorder(),
                      color: Colors.blue,
                      child: Text("Tambah"),
                      onPressed: () async {
                        print(widget.userModel.dataDriver);
                        // if (widget.userModel.dataDriver == null) {
                        if (uploadKendaraanController.text.isEmpty ||
                            merkController.text.isEmpty ||
                            jenisController.text.isEmpty ||
                            platNoController.text.isEmpty) {
                          QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              text: "Harap lengkapi field");
                        } else {
                          if (newListKendaraanDriver
                              .where((element) =>
                                  element.platNo.toString() ==
                                  platNoController.text)
                              .isEmpty) {
                            setState(() {
                              loadingButtonVehicle = false;
                            });

                            updloadFiles(_image2, "kendaraan");
                          } else {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                text: "Plat nomor tidak boleh sama");
                          }
                        }

                        /* setState(() {
                        newListKendaraanDriver.add(KendaraanDriver(
                            jenis: jenisController.text,
                            merk: merkController.text,
                            platNo: platNoController.text,
                            fotoKendaraan: uploadKendaraanController.text,
                            keteranganKendaraan: "On Review",
                            status: 0));
                        newFileKendaraan.add(_image2);
                      }); */
                        //  }
                      })
                  : Center(
                      child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: CircularProgressIndicator())),
            ),
            newListKendaraanDriver.length == 0
                ? Container()
                : listKendaraanDriver()
          ],
        ),
      ),
    );
  }

  Widget listDokumenDriver() {
    return Container(
      width: double.infinity,
      height: 280,
      child: ListView.builder(
          itemCount: newListDokumenDriver.length,
          itemBuilder: (context, index) {
            return Container(
              child: Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                            "https://asset.smartrans.id/uploads/${newListDokumenDriver[index].fotoDokumen}"),
                      ),
                      ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(newListDokumenDriver[index]
                                  .jenisDokumen
                                  .toString()),
                              Text(newListDokumenDriver[index].nid.toString()),
                              Text("${newListDokumenDriver[index].datevalid}"),
                              Text(newListDokumenDriver[index]
                                  .keteranganDokumen
                                  .toString())
                            ],
                          ),
                          trailing: Material(
                            shape: StadiumBorder(),
                            elevation: 2,
                            child: IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Center(
                                          child: Container(
                                            height: 120,
                                            padding: EdgeInsets.all(15),
                                            margin: EdgeInsets.all(28),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                color: Colors.white),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Apakah anda yakin ?",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    MaterialButton(
                                                        shape: StadiumBorder(),
                                                        color: Colors.red,
                                                        child: Text("Yes"),
                                                        onPressed: () {
                                                          deleteDataDriver(
                                                              index, "dokumen");
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                    MaterialButton(
                                                        shape: StadiumBorder(),
                                                        color: Colors.grey,
                                                        child: Text("No"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        })
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                  size: 28,
                                )),
                          )),
                    ],
                  ),

                  /* Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Jenis"),
                              Text("NID"),
                              Text("Berlaku"),
                              Text("Keterangan")
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(newListDokumenDriver[index]
                                  .jenisDokumen
                                  .toString()),
                              Text(newListDokumenDriver[index].nid.toString()),
                              Text("${newListDokumenDriver[index].datevalid}"),
                              Text(newListDokumenDriver[index]
                                  .keteranganDokumen
                                  .toString())
                            ],
                          ),
                          SizedBox(width: 5),
                          Container(
                            padding: EdgeInsets.only(bottom: 18),
                            //child: Image.network(newFileDokumen[index]),
                            child: Image.network(
                                "https://asset.smartrans.id/uploads/${newListDokumenDriver[index].fotoDokumen}"),
                            height: 80,
                            width: 70,
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                        child: Container(
                                          height: 120,
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Colors.white),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Apakah anda yakin ?",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  MaterialButton(
                                                      shape: StadiumBorder(),
                                                      color: Colors.red,
                                                      child: Text("Yes"),
                                                      onPressed: () {
                                                        deleteDataDriver(
                                                            index, "dokumen");
                                                        Navigator.pop(context);
                                                      }),
                                                  MaterialButton(
                                                      shape: StadiumBorder(),
                                                      color: Colors.grey,
                                                      child: Text("No"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      })
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                                size: 28,
                              ))
                        ],
                      ),
                    ],
                  ), */
                ),
              ),
            );
          }),
    );
  }

  Widget listKendaraanDriver() {
    return Container(
      height: 280,
      child: ListView.builder(
          itemCount: newListKendaraanDriver.length,
          itemBuilder: (context, index) {
            return Container(
              child: Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                            "https://asset.smartrans.id/uploads/${newListKendaraanDriver[index].fotoKendaraan}"),
                      ),
                      ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                newListKendaraanDriver[index].jenis.toString()),
                            Text(newListKendaraanDriver[index].merk.toString()),
                            Text(newListKendaraanDriver[index]
                                .platNo
                                .toString()),
                            Text(newListKendaraanDriver[index]
                                .keteranganKendaraan
                                .toString())
                          ],
                        ),
                        trailing: Material(
                          shape: StadiumBorder(),
                          elevation: 2,
                          child: IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                        child: Container(
                                          height: 120,
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Colors.white),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Apakah anda yakin ?",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  MaterialButton(
                                                      shape: StadiumBorder(),
                                                      color: Colors.red,
                                                      child: Text("Yes"),
                                                      onPressed: () {
                                                        deleteDataDriver(
                                                            index, "kendaraan");
                                                        Navigator.pop(context);
                                                      }),
                                                  MaterialButton(
                                                      shape: StadiumBorder(),
                                                      color: Colors.grey,
                                                      child: Text("No"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      })
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                                size: 28,
                              )),
                        ),
                      ),
                    ],
                  ),

                  /* Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Jenis"),
                              Text("Merk"),
                              Text("Plat NoPol"),
                              Text("Keterangan"),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(newListKendaraanDriver[index]
                                  .jenis
                                  .toString()),
                              Text(newListKendaraanDriver[index]
                                  .merk
                                  .toString()),
                              Text(newListKendaraanDriver[index]
                                  .platNo
                                  .toString()),
                              Text(newListKendaraanDriver[index]
                                  .keteranganKendaraan
                                  .toString())
                            ],
                          ),
                          SizedBox(width: 5),
                          Container(
                            padding: EdgeInsets.only(bottom: 18),
                            //child: Image.file(newFileKendaraan[index]),
                            child: Image.network(
                                "https://asset.smartrans.id/uploads/${newListKendaraanDriver[index].fotoKendaraan}"),
                            height: 80,
                            width: 70,
                          ),
                          SizedBox(width: 5),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                        child: Container(
                                          height: 120,
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Colors.white),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Apakah anda yakin ?",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  MaterialButton(
                                                      shape: StadiumBorder(),
                                                      color: Colors.red,
                                                      child: Text("Yes"),
                                                      onPressed: () {
                                                        deleteDataDriver(
                                                            index, "kendaraan");
                                                        Navigator.pop(context);
                                                      }),
                                                  MaterialButton(
                                                      shape: StadiumBorder(),
                                                      color: Colors.grey,
                                                      child: Text("No"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      })
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                                size: 28,
                              ))
                        ],
                      ),
                    ],
                  ), */
                ),
              ),
            );
          }),
    );
  }

  List<Widget> tabsContent() => <Widget>[
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dokumen Driver',
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 35.0),
              buildDokumenDriverForm(),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kendaraan Driver',
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 35.0),
              buildKendaraanDriverForm(),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.orange),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendaftaran sebagai driver',
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 50.0),
                const Text(
                  "Dengan ini anda menyatakan mendaftar sebagai driver, harap periksa kembali kelengkapan data dengan baik untuk direview oleh admin",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  width: double.infinity,
                  child: MaterialButton(
                      color: Colors.lightGreen,
                      child: Text("Simpan"),
                      onPressed: () {
                        if (newListDokumenDriver.length == 0) {
                          QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              text: 'Maaf data dokumen anda masih kosong',
                              autoCloseDuration: Duration(seconds: 2));
                        } else {
                          if (newListKendaraanDriver.length == 0) {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                text: 'Maaf data kendaraan anda masih kosong',
                                autoCloseDuration: Duration(seconds: 2));
                          } else {
                            print("isi");
                            showDialog(
                                context: (context),
                                builder: (context) {
                                  return LogoandSpinner(
                                    imageAssets: 'images/loadingsmartrans.png',
                                    reverse: false,
                                    arcColor: primaryColor,
                                    spinSpeed: Duration(milliseconds: 500),
                                  );
                                });
                            updateUser();
                            /* saveDataDriver();
                            Future.delayed(Duration(seconds: 4), () {
                              Navigator.of(context, rootNavigator: true).pop();

                              QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  text: 'Berkas sedang di review oleh admin',
                                  autoCloseDuration: Duration(seconds: 2));
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DriverHome(
                                          userModel: widget.userModel,
                                          isDriver: true)));
                            }); */
                          }
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ];

  List<Widget> tabsTitle(BuildContext context) => <Widget>[
        Icon(
          Icons.perm_identity_outlined,
        ),
        Icon(
          Icons.directions_car,
        ),
        Icon(
          Icons.save_alt_outlined,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: primaryColor),
              child: Row(
                children: [
                  IconButton(
                      iconSize: 25,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PassengerHome(
                                    userModel: widget.userModel,
                                    isDriver: false)));
                      },
                      icon: Icon(Icons.arrow_back))
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: TabContainer(
                  tabCurve: Curves.easeInToLinear,
                  tabDuration: Duration(milliseconds: 500),
                  color: primaryColor,
                  tabEdge: TabEdge.left,
                  tabStart: 0,
                  tabEnd: 1,
                  childPadding: const EdgeInsets.all(10.0),
                  children: tabsContent(),
                  tabs: tabsTitle(context),
                  isStringTabs: false,
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                  unselectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
