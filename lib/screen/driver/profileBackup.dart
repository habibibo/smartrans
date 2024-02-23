import 'dart:convert';
import 'dart:io';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:intl_phone_field/intl_phone_field.dart';
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
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:tab_container/tab_container.dart';

SelectOption? selectedOption;
SelectOption? categoryDocument;
List<DokumenDriver> newListDokumenDriver = [];
List<DokumenDriver> tempListDokumenDriver = [];
List<KendaraanDriver> newListKendaraanDriver = [];
List<KendaraanDriver> tempListKendaraanDriver = [];

TextEditingController dateBirthController = TextEditingController();
TextEditingController phoneController = TextEditingController();
String countryCode = "";
String foto_akun = "";
TextEditingController nidController = TextEditingController();
TextEditingController jenis_dokumenController = TextEditingController();
TextEditingController datevalidController = TextEditingController();
TextEditingController keterangan_dokumenController = TextEditingController();
TextEditingController statusController = TextEditingController();
TextEditingController uploadDokumenController = TextEditingController();

TextEditingController jenisController = TextEditingController();
TextEditingController merkController = TextEditingController();
TextEditingController platNoController = TextEditingController();
TextEditingController fotoKendaraanController = TextEditingController();
TextEditingController keteranganKendaraanController = TextEditingController();
TextEditingController jobController = TextEditingController();
TextEditingController uploadKendaraanController = TextEditingController();

List<File> tempFileDokumen = [];
List<File> tempFileKendaraan = [];
late File _image;
late File _image2;

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

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class SelectOption {
  final String label;
  final String value;

  SelectOption({required this.label, required this.value});
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TabContainerController _controller =
      TabContainerController(length: 2);
  late TextTheme textTheme;
  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print(widget.userModel.email);
    var jsonUserModel = jsonEncode(widget.userModel.toJson());
    print(jsonDecode(jsonDecode(jsonUserModel)["data_account"]));
    print(jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"]);
    setState(() {
      dateBirthController.text = jsonDecode(
          jsonDecode(jsonUserModel)["data_account"])["tanggal_lahir"];
      countryCode =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
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

      var decode = jsonDecode(widget.userModel.dataDriver.toString());
      List<dynamic> jsonDokumen = json.decode(decode["dokumen_driver"]);
      List<dynamic> jsonKendaraan = json.decode(decode["kendaraan_driver"]);
      // Convert List<Map<String, dynamic>> to List<DokumenDriver>
      newListDokumenDriver =
          jsonDokumen.map((json) => DokumenDriver.fromJson(json)).toList();
      newListKendaraanDriver =
          jsonKendaraan.map((json) => KendaraanDriver.fromJson(json)).toList();
    });
  }

  void updateUser() {
    if (tempFileDokumen.length == 0 && tempFileKendaraan.length == 0) {
      saveUser();
    } else {
      if (tempFileDokumen.length != 0) {
        for (int i = 0; i <= tempFileDokumen.length - 1; i++) {
          uploadBerkas(tempFileDokumen[i], "dokumen", i);
          Future.delayed(Duration(seconds: 1));
        }
      }
      if (tempFileKendaraan.length != 0) {
        for (int i2 = 0; i2 <= tempFileKendaraan.length - 1; i2++) {
          uploadBerkas(tempFileKendaraan[i2], "kendaraan", i2);
          Future.delayed(Duration(seconds: 1));
        }
      }
      Future.delayed(Duration(seconds: 4), () {
        saveUser();
      });
    }

    /* var decodeDriver = jsonDecode(widget.userModel.dataDriver.toString());
    final dataDriver = {
      "keterangan_driver": decodeDriver["keterangan_driver"],
      "status_driver": decodeDriver["status_driver"],
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
    LoginRepo().updateUser(userData); */
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
          tempListDokumenDriver[index].fotoDokumen =
              jsonDecode(streamREesponse.body)["filename"];
          print(tempListDokumenDriver[index].fotoDokumen);
        });
      }
      if (type == "kendaraan") {
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          print("kendaraan");
          tempListKendaraanDriver[index].fotoKendaraan =
              jsonDecode(streamREesponse.body)["filename"];
          print(tempListKendaraanDriver[index].fotoKendaraan);
        });
      }
    } else {
      print("error");
    }
  }

  void saveUser() async {
    setState(() {
      //widget.userModel.dataAccount = jsonEncode(dataAccount);
      if (tempListDokumenDriver.length != 0) {
        setState(() {
          newListDokumenDriver.addAll(tempListDokumenDriver);
        });
      }
      if (tempListKendaraanDriver.length != 0) {
        setState(() {
          newListKendaraanDriver.addAll(tempListKendaraanDriver);
        });
      }
    });
    var decodeAccount = jsonDecode(widget.userModel.dataAccount.toString());
    var decodeDriver = jsonDecode(widget.userModel.dataDriver.toString());
    final dataDriver = {
      "keterangan_driver": decodeDriver["keterangan_driver"],
      "status_driver": decodeDriver["status_driver"],
      "dokumen_driver": jsonEncode(newListDokumenDriver),
      "kendaraan_driver": jsonEncode(newListKendaraanDriver),
      "onoff": 1,
    };
    final dataAccount =
        "{\"mode\": [\"driver\"], \"phone\": {\"phoneno\": \"${phoneController.text}\", \"countrycode\": \"${countryCode}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${widget.userModel.email}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"driver\", \"status_akun\": \"${decodeAccount['status_akun']}\", \"tanggal_lahir\": \"${dateBirthController.text}\"}";
    /* final dataAccount = {
      "mode": ["driver"],
      "phone": {
        "phone": phoneController.text,
        "countrycode": countryCode,
        "verified_wa": "0",
        "verified_sms": "0",
      },
      "username": widget.userModel.email,
      "foto_akun": foto_akun,
      "active_mode": "driver",
      "status_akun": 1,
      "tanggal_lahir": dateBirthController.text
    }; */

    final userData = {
      "id": widget.userModel.id,
      "uid": widget.userModel.uid,
      "email": widget.userModel.email,
      "token": widget.userModel.token,
      "data_account": dataAccount,
      "rating": widget.userModel.rating,
      "data_driver": jsonEncode(dataDriver),
      "location": widget.userModel.location,
      "created": widget.userModel.created,
      "deposit": widget.userModel.deposit,
      "transaction": widget.userModel.transaction,
      "point": widget.userModel.point
    };

    updateUserCache(userData.toString());
    LoginRepo().updateUser(userData);
    setState(() {
      widget.userModel.dataAccount = dataAccount;
      widget.userModel.dataDriver = jsonEncode(dataDriver);
      tempFileDokumen.clear();
      tempFileKendaraan.clear();
      tempListDokumenDriver.clear();
      tempListKendaraanDriver.clear();
      tempFileDokumen = [];
      tempFileKendaraan = [];
      tempListDokumenDriver = [];
      tempListKendaraanDriver = [];

      jenis_dokumenController.clear();
      datevalidController.clear();
      uploadDokumenController.clear();

      jenisController.clear();
      merkController.clear();
      platNoController.clear();
      fotoKendaraanController.clear();
      uploadKendaraanController.clear();
      //Navigator.of(context).pop();
      //Navigator.pop(context);
    });
  }

  void updateUserCache(String userData) async {
    SharedPreferences userCache = await SharedPreferences.getInstance();
    userCache.setString("userModel", userData);
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

  void showAddBerkasDriver(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return ShowAddBerkas(userModel: widget.userModel);
        });
  }

  void prepareUpdate() {
    updateUser();
    showDialog(
        barrierDismissible: false,
        context: (context),
        builder: (context) {
          return LogoandSpinner(
            imageAssets: 'images/loadingsmartrans.png',
            reverse: false,
            arcColor: primaryColor,
            spinSpeed: Duration(milliseconds: 500),
          );
        });
    Future.delayed(Duration(seconds: 6), () {
      Navigator.of(context, rootNavigator: true).pop();
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Data berhasil disimpan");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 30, left: 5, right: 5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: primaryColor),
                child: Card(
                  color: primaryColor,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 15,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      children: [
                        Container(
                            child: ListTile(
                          leading: ClipOval(
                            child: Container(
                              //child: Icon(Icons.person),
                              child: Image.network(foto_akun),
                            ),
                          ),
                          title: Text(widget.userModel.email.toString()),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 700,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [Text("Data pribadi")],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: TextField(
                              decoration:
                                  InputDecoration(labelText: "Tanggal Lahir"),
                              controller: dateBirthController,
                              readOnly: true,
                              onTap: () async {
                                DateTime? dateTime = await showDatePicker(
                                    onDatePickerModeChange: (value) {
                                      setState(() {
                                        dateBirthController.text =
                                            value.toString();
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
                                    dateBirthController.text = formattedDate;
                                  });
                                }
                              },
                            ),
                          ),
                          Container(
                              child: Text(
                                  "phone") /* IntlPhoneField(
                              controller: phoneController,
                              initialCountryCode: Countries.findByDialCode(
                                      "+${countryCode.toString()}")
                                  .first
                                  .code,
                              initialValue: phoneController.text,
                              onChanged: (number) {
                                print(number.completeNumber);
                              },
                              onCountryChanged: (value) {
                                countryCode = value.dialCode;
                                print(value.dialCode);
                              },
                            ), */
                              ),
                          Container(
                            width: double.infinity,
                            height: 400,
                            child: TabContainer(
                              color: Colors.orangeAccent[100],
                              tabs: [
                                Icon(
                                  Icons.document_scanner,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                Icon(
                                  Icons.directions_car,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              ],
                              isStringTabs: false,
                              controller: _controller,
                              childPadding: EdgeInsets.all(10),
                              radius: 25,
                              tabDuration: const Duration(milliseconds: 600),
                              selectedTextStyle: textTheme.bodyText2
                                  ?.copyWith(color: Colors.white),
                              unselectedTextStyle: textTheme.bodyText2
                                  ?.copyWith(color: Colors.black),
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: newListDokumenDriver.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        child: Card(
                                          elevation: 5,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            newListDokumenDriver[
                                                                    index]
                                                                .jenisDokumen
                                                                .toString()),
                                                        Text(
                                                            newListDokumenDriver[
                                                                    index]
                                                                .nid
                                                                .toString()),
                                                        Text(
                                                            "${newListDokumenDriver[index].datevalid}"),
                                                        Text(newListDokumenDriver[
                                                                index]
                                                            .keteranganDokumen
                                                            .toString())
                                                      ],
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          bottom: 18),
                                                      child: Image.network(
                                                          "https://asset.smartrans.id/uploads/${newListDokumenDriver[index].fotoDokumen.toString()}"),
                                                      height: 80,
                                                      width: 80,
                                                    ),
                                                    SizedBox(width: 5),
                                                    IconButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return Center(
                                                                  child:
                                                                      Container(
                                                                    height: 120,
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            15),
                                                                    margin: EdgeInsets
                                                                        .all(
                                                                            40),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(
                                                                                20)),
                                                                        color: Colors
                                                                            .white),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          "Apakah anda yakin ?",
                                                                          style:
                                                                              TextStyle(fontSize: 20),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            MaterialButton(
                                                                                shape: StadiumBorder(),
                                                                                color: Colors.red,
                                                                                child: Text("Yes"),
                                                                                onPressed: () {
                                                                                  deleteDataDriver(index, "dokumen");
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
                                                          size: 40,
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                Container(
                                  height: 300,
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
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text("Jenis"),
                                                          Text("Merk"),
                                                          Text("Plat NoPol"),
                                                          Text("Keterangan"),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              newListKendaraanDriver[
                                                                      index]
                                                                  .jenis
                                                                  .toString()),
                                                          Text(
                                                              newListKendaraanDriver[
                                                                      index]
                                                                  .merk
                                                                  .toString()),
                                                          Text(
                                                              newListKendaraanDriver[
                                                                      index]
                                                                  .platNo
                                                                  .toString()),
                                                          Text(newListKendaraanDriver[
                                                                  index]
                                                              .keteranganKendaraan
                                                              .toString())
                                                        ],
                                                      ),
                                                      SizedBox(width: 10),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 18),
                                                        child: Image.network(
                                                            "https://asset.smartrans.id/uploads/${newListKendaraanDriver[index].fotoKendaraan.toString()}"),
                                                        height: 80,
                                                        width: 100,
                                                      ),
                                                      SizedBox(width: 5),
                                                      IconButton(
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Center(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          120,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              15),
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              40),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(
                                                                              20)),
                                                                          color:
                                                                              Colors.white),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Text(
                                                                            "Apakah anda yakin ?",
                                                                            style:
                                                                                TextStyle(fontSize: 20),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              MaterialButton(
                                                                                  shape: StadiumBorder(),
                                                                                  color: Colors.red,
                                                                                  child: Text("Yes"),
                                                                                  onPressed: () {
                                                                                    deleteDataDriver(index, "kendaraan");
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
                                                            Icons
                                                                .delete_forever,
                                                            color: Colors.red,
                                                            size: 40,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          MaterialButton(
                              shape: const StadiumBorder(),
                              color: primaryColor,
                              minWidth: double.infinity,
                              child: Text("Simpan perubahan"),
                              onPressed: () async {
                                if (newListDokumenDriver.isEmpty) {
                                  if (tempListDokumenDriver.isEmpty) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.info,
                                        text: "Harap tambahkan dokumen anda");
                                  } else {
                                    if (newListKendaraanDriver.isEmpty) {
                                      if (tempListKendaraanDriver.isEmpty) {
                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.info,
                                            text:
                                                "Harap tambahkan kendaraan anda");
                                      } else {
                                        prepareUpdate();
                                      }
                                    } else {
                                      prepareUpdate();
                                    }
                                  }
                                } else {
                                  if (newListKendaraanDriver.isEmpty) {
                                    if (tempListKendaraanDriver.isEmpty) {
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.info,
                                          text:
                                              "Harap tambahkan kendaraan anda");
                                    } else {
                                      prepareUpdate();
                                    }
                                  } else {
                                    prepareUpdate();
                                  }
                                }
                              }),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FloatingActionButton(
                                  tooltip: "test",
                                  child: Icon(Icons.add),
                                  onPressed: () {
                                    // ScrollController scrollController;
                                    /* showFlexibleBottomSheet(
                                      bottomSheetBorderRadius:
                                          BorderRadius.only(),
                                      minHeight: 1,
                                      initHeight: 1,
                                      maxHeight: 1,
                                      context: context,
                                      builder: (context, controller, offset) {
                                        return Material(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            )),
                                            child: Text("test"),
                                          ),
                                        );
                                      },
                                      isExpand: false,
                                    ); */
                                    showAddBerkasDriver(context);
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class ShowAddBerkas extends StatefulWidget {
  ShowAddBerkas({Key? key, required this.userModel}) : super(key: key);
  UserModel userModel;

  @override
  State<ShowAddBerkas> createState() => _ShowAddBerkasState();
}

class _ShowAddBerkasState extends State<ShowAddBerkas> {
  final picker = ImagePicker();
  Future getImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadDokumenController.text = pickedFile.name;
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

  Widget buildDokumenDriverForm() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
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
                controller: uploadDokumenController,
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
                  shape: StadiumBorder(),
                  color: Colors.blue,
                  child: Text("Tambah"),
                  onPressed: () async {
                    setState(() {
                      tempListDokumenDriver.add(DokumenDriver(
                          nid: nidController.text,
                          jenisDokumen: jenis_dokumenController.text,
                          fotoDokumen: uploadDokumenController.text,
                          datevalid: datevalidController.text,
                          keteranganDokumen: "On Review",
                          status: 0));
                      tempFileDokumen.add(_image);
                    });
                  }),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text("List dokumen"),
            ),
            SizedBox(
              height: 5,
            ),
            tempListDokumenDriver.length == 0
                ? Container()
                : listDokumenDriver()
          ],
        ),
      ),
    );
  }

  Widget buildKendaraanDriverForm() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
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
                  shape: StadiumBorder(),
                  color: Colors.blue,
                  child: Text("Tambah"),
                  onPressed: () async {
                    print(widget.userModel.dataDriver);
                    //if (widget.userModel.dataDriver == null) {
                    setState(() {
                      tempListKendaraanDriver.add(KendaraanDriver(
                          jenis: jenisController.text,
                          merk: merkController.text,
                          platNo: platNoController.text,
                          fotoKendaraan: uploadKendaraanController.text,
                          keteranganKendaraan: "On Review",
                          status: 0));
                      tempFileKendaraan.add(_image2);
                      //Navigator.pop(context);
                      //showAddBerkasDriver(context);
                    });
                    //   }
                  }),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text("List kendaraan"),
            ),
            SizedBox(
              height: 5,
            ),
            tempListKendaraanDriver.length == 0
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
      height: 300,
      child: ListView.builder(
          itemCount: tempListDokumenDriver.length,
          itemBuilder: (context, index) {
            return Container(
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
                              Text(tempListDokumenDriver[index]
                                  .jenisDokumen
                                  .toString()),
                              Text(tempListDokumenDriver[index].nid.toString()),
                              Text("${tempListDokumenDriver[index].datevalid}"),
                              Text(tempListDokumenDriver[index]
                                  .keteranganDokumen
                                  .toString()),
                            ],
                          ),
                          SizedBox(width: 20),
                          Container(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Image.file(tempFileDokumen[index]),
                            height: 80,
                            width: 80,
                          ),
                          IconButton(
                              padding: EdgeInsets.only(top: 15),
                              onPressed: () {
                                setState(() {
                                  tempListDokumenDriver.removeAt(index);
                                  tempFileDokumen.removeAt(index);
                                  //Navigator.pop(context);
                                  //showAddBerkasDriver(context);
                                });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                size: 35,
                                color: Colors.red,
                              ))
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
          itemCount: tempListKendaraanDriver.length,
          itemBuilder: (context, index) {
            return Container(
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
                              Text(tempListKendaraanDriver[index]
                                  .jenis
                                  .toString()),
                              Text(tempListKendaraanDriver[index]
                                  .merk
                                  .toString()),
                              Text(tempListKendaraanDriver[index]
                                  .platNo
                                  .toString()),
                              Text(tempListKendaraanDriver[index]
                                  .keteranganKendaraan
                                  .toString())
                            ],
                          ),
                          SizedBox(width: 20),
                          Container(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Image.file(tempFileKendaraan[index]),
                            height: 80,
                            width: 80,
                          ),
                          IconButton(
                              padding: EdgeInsets.only(top: 15),
                              onPressed: () {
                                setState(() {
                                  tempListKendaraanDriver.removeAt(index);
                                  tempFileKendaraan.removeAt(index);
                                  //Navigator.pop(context);
                                  //showAddBerkasDriver(context);
                                });
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                size: 35,
                                color: Colors.red,
                              ))
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
        /* SingleChildScrollView(
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
                  style: TextStyle(color: Colors.white),
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
                            //saveDataDriver();
                            Future.delayed(Duration(seconds: 4), () {
                              Navigator.of(context, rootNavigator: true).pop();

                              QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  text: 'Berkas sedang di review oleh admin',
                                  autoCloseDuration: Duration(seconds: 2));
                            });
                          }
                        }
                      }),
                ),
              ],
            ),
          ),
        ), */
      ];

  List<Widget> tabsTitle(BuildContext context) => <Widget>[
        Icon(
          Icons.document_scanner,
        ),
        Icon(
          Icons.directions_car,
        ),
        /* Icon(
          Icons.save_alt_outlined,
        ), */
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white),
      height: double.maxFinite,
      width: double.infinity,
      padding: EdgeInsets.all(15),
      child: TabContainer(
        tabCurve: Curves.easeInToLinear,
        tabDuration: Duration(milliseconds: 500),
        color: primaryColor,
        tabEdge: TabEdge.top,
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
    );
  }
}
