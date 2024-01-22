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
import 'package:signgoogle/model/dokumen_driver.dart';
import 'package:signgoogle/model/kendaraan_driver.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/screen/driver/home.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:http/http.dart' as http;

class BerkasDriver extends StatefulWidget {
  GoogleSignInAccount? user;
  UserModel userModel;
  BerkasDriver({Key? key, required this.user, required this.userModel})
      : super(key: key);

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
    SelectOption(label: 'SIM A', value: 'SIM_A'),
    SelectOption(label: 'SIM B', value: 'SIM_B'),
    SelectOption(label: 'SIM C', value: 'SIM_C'),
  ];

  SelectOption? selectedOption;
  SelectOption? categoryDocument;
  bool showAddDokumenDriver = true;
  bool showAddKendaraanDriver = false;
  List<DokumenDriver> newListDokumenDriver = [];
  List<KendaraanDriver> newListKendaraanDriver = [];

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
    print(Countries.findByDialCode("+${countryCode}").first.flag);
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
        if (i == newFileDokumen.length - 1) {
          for (int i2 = 0; i2 <= newFileKendaraan.length - 1; i2++) {
            uploadBerkas(newFileKendaraan[i2], "kendaraan", i2);
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
          LoginRepo().updateUser(userData);
        }
      }
    } else {
      print("error");
    }
  }

  Widget buildDokumenDriverForm() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Card(
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                        DropdownButton<SelectOption>(
                          value: categoryDocument ?? categoryDocuments[0],
                          onChanged: (SelectOption? newValue) {
                            setState(() {
                              jenis_dokumenController.text = newValue!.value;
                              print(jenis_dokumenController.text);
                              // Reset forms when changing utilityDriver
                              //dokumenDriverForm = DokumenDriverForm();
                              //kendaraanDriverForm = KendaraanDriverForm();
                            });
                          },
                          items: categoryDocuments.map((SelectOption option) {
                            return DropdownMenuItem<SelectOption>(
                              value: option,
                              child: Text(option.label),
                            );
                          }).toList(),
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
                  child: MaterialButton(
                      color: Colors.blue,
                      child: Text("Tambah"),
                      onPressed: () async {
                        setState(() {
                          newListDokumenDriver.add(DokumenDriver(
                              nid: nidController.text,
                              jenisDokumen: jenis_dokumenController.text,
                              fotoDokumen: uploadImageController.text,
                              datevalid: datevalidController.text,
                              keteranganDokumen: "On Review",
                              status: 0));
                          newFileDokumen.add(_image);
                        });
                      }),
                ),
                newListDokumenDriver.length == 0
                    ? Container()
                    : listDokumenDriver()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildKendaraanDriverForm() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Card(
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    child: TextField(
                  controller: jenisController,
                  decoration: InputDecoration(
                    labelText: "Jenis",
                    icon: Icon(Icons.directions_car_filled_outlined),
                  ),
                )),
                Container(
                  child: TextField(
                    controller: merkController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.directions_car_filled_outlined),
                      labelText: "Merk",
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
                  child: MaterialButton(
                      color: Colors.blue,
                      child: Text("Tambah"),
                      onPressed: () async {
                        print(widget.userModel.dataDriver);
                        if (widget.userModel.dataDriver == null) {
                          setState(() {
                            newListKendaraanDriver.add(KendaraanDriver(
                                jenis: jenisController.text,
                                merk: merkController.text,
                                platNo: platNoController.text,
                                fotoKendaraan: uploadKendaraanController.text,
                                keteranganKendaraan: "On Review",
                                status: 0));
                            newFileKendaraan.add(_image2);
                          });
                        }
                      }),
                ),
                newListKendaraanDriver.length == 0
                    ? Container()
                    : listKendaraanDriver()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listDokumenDriver() {
    return Container(
      height: 300,
      child: ListView.builder(
          itemCount: newListDokumenDriver.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(10),
              child: Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
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
                            width: 20,
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
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Image.file(newFileDokumen[index]),
                            height: 80,
                            width: 100,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget listKendaraanDriver() {
    return Container(
      height: 300,
      child: ListView.builder(
          itemCount: newListKendaraanDriver.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(10),
              child: Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
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
                              Text("Foto Kendaraan"),
                              Text("Keterangan"),
                            ],
                          ),
                          SizedBox(
                            width: 20,
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
                              Text(
                                  "${newListKendaraanDriver[index].fotoKendaraan.toString().substring(1, 5)}..."),
                              Text(newListKendaraanDriver[index]
                                  .keteranganKendaraan
                                  .toString())
                            ],
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Image.file(newFileKendaraan[index]),
                            height: 80,
                            width: 100,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                                  user: widget.user, isDriver: false)));
                    },
                    icon: Icon(Icons.arrow_back))
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 10, right: 10),
            padding: EdgeInsets.all(12),
            color: Colors.blueGrey,
            child: Material(
              color: Colors.transparent,
              child: Text(
                "Harap masukkan berkas driver",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            showAddDokumenDriver = true;
                            showAddKendaraanDriver = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.lightBlueAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Icon(
                                Icons.document_scanner_outlined,
                                size: 45,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Dokumen Driver")
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            showAddDokumenDriver = false;
                            showAddKendaraanDriver = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.cyanAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 45,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Kendaraan Driver"),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 600,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                      visible: showAddDokumenDriver,
                      child: buildDokumenDriverForm()),
                  Visibility(
                      visible: showAddKendaraanDriver,
                      child: buildKendaraanDriverForm()),
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
                                      imageAssets:
                                          'images/loadingsmartrans.png',
                                      reverse: false,
                                      arcColor: primaryColor,
                                      spinSpeed: Duration(milliseconds: 500),
                                    );
                                  });
                              saveDataDriver();
                              Future.delayed(Duration(seconds: 4), () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    text: 'Berkas sedang di review oleh admin',
                                    autoCloseDuration: Duration(seconds: 2));
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DriverHome(
                                            user: widget.user,
                                            isDriver: true)));
                              });
                            }
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
