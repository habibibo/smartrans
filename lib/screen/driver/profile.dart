import 'dart:convert';
import 'dart:io';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:mime/mime.dart';
import 'package:phonecodes/phonecodes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/dokumen_driver.dart';
import 'package:signgoogle/model/kendaraan_driver.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/passenger.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/basic_auth.dart';

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

    var decode = jsonDecode(widget.userModel.dataDriver.toString());
    List<dynamic> jsonDokumen = json.decode(decode["dokumen_driver"]);
    List<dynamic> jsonKendaraan = json.decode(decode["kendaraan_driver"]);
    // Convert List<Map<String, dynamic>> to List<DokumenDriver>
    newListDokumenDriver =
        jsonDokumen.map((json) => DokumenDriver.fromJson(json)).toList();
    newListKendaraanDriver =
        jsonKendaraan.map((json) => KendaraanDriver.fromJson(json)).toList();
  }

  late File _image;
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

  Widget buildDokumenDriverForm() {
    return Container(
      child: Column(
        children: [
          Container(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.card_travel),
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
              controller: nidController,
              decoration: InputDecoration(
                icon: Icon(Icons.wallet_membership),
                labelText: "No ID",
              ),
            ),
          ),
          Container(
            child: TextField(
              controller: uploadImageController,
              decoration: InputDecoration(
                icon: Icon(Icons.image),
                labelText: "Upload Gambar",
              ),
              onTap: () => getImage(),
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(labelText: "Tanggal berlaku"),
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
                child: Text("Simpan"),
                onPressed: () async {
                  print(widget.userModel.dataDriver);
                  if (widget.userModel.dataDriver == null) {
                    String addimageUrl =
                        'https://asset.smartrans.id/upload_image.php';
                    Map<String, String> headers = {
                      'Authorization': "Basic YmFzZTY0OmVtYWls",
                      'Content-type': 'multipart/form-data',
                    };
                    var request =
                        http.MultipartRequest('POST', Uri.parse(addimageUrl));
                    request.headers.addAll(headers);
                    String? mimeType = lookupMimeType(_image.path);
                    var multipartFile = http.MultipartFile(
                      'image', // The name of the field for the file
                      http.ByteStream.fromBytes(_image.readAsBytesSync()),
                      _image.lengthSync(),
                      filename: 'image_file.jpg',
                      contentType: MediaType.parse(mimeType!),
                    );
                    request.files.add(multipartFile);

                    var response = await request.send();
                    var streamREesponse =
                        await http.Response.fromStream(response);
                    if (response.statusCode == 200) {
                      final jsonDokumenDriver = [
                        {
                          "nid": nidController.text,
                          "jenis_dokumen": jenis_dokumenController.text,
                          "foto_dokumen":
                              jsonDecode(streamREesponse.body)["filename"],
                          "datevalid": datevalidController.text,
                          "keterangan_dokumen": "On Review",
                          "status": 0
                        }
                      ];
                      print(jsonDokumenDriver);
                      final dataDriver = {
                        "keterangan_driver": "Menunggu Aktivasi",
                        "status_driver": 0,
                        "dokumen_driver": jsonDokumenDriver,
                        "kendaraan_driver": []
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
                    } else {
                      print("error");
                    }
                  } else {}
                }),
          ),
        ],
      ),
    );
  }

  Widget buildKendaraanDriverForm() {
    return Container(
      child: Text("kendaraan driver"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 30, left: 5, right: 5),
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
                          child: IntlPhoneField(
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
                          ),
                        ),
                        /* Container(
                            alignment: Alignment.topLeft,
                            child: DropdownButton<SelectOption>(
                              value: selectedOption ?? utilityDriver[0],
                              onChanged: (SelectOption? newValue) {
                                setState(() {
                                  selectedOption = newValue;
                                  print(selectedOption!.value);
                                  // Reset forms when changing utilityDriver
                                  //dokumenDriverForm = DokumenDriverForm();
                                  //kendaraanDriverForm = KendaraanDriverForm();
                                });
                              },
                              items: utilityDriver.map((SelectOption option) {
                                return DropdownMenuItem<SelectOption>(
                                  value: option,
                                  child: Text(option.label),
                                );
                              }).toList(),
                            )), */
                        if (selectedOption != null)
                          selectedOption!.value == 'dokumen_driver'
                              ? buildDokumenDriverForm()
                              : buildKendaraanDriverForm(),
                        Accordion(
                            headerBorderColor: Colors.blueGrey,
                            headerBorderColorOpened: Colors.transparent,
                            // headerBorderWidth: 1,
                            headerBackgroundColorOpened: Colors.lightBlueAccent,
                            contentBackgroundColor: Colors.white,
                            contentBorderColor: Colors.lightBlueAccent,
                            contentBorderWidth: 3,
                            contentHorizontalPadding: 10,
                            scaleWhenAnimating: false,
                            openAndCloseAnimation: false,
                            headerPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 15),
                            /*  sectionOpeningHapticFeedback:
                                SectionHapticFeedback.heavy,
                            sectionClosingHapticFeedback:
                                SectionHapticFeedback.light, */
                            children: [
                              AccordionSection(
                                isOpen: false,
                                contentVerticalPadding: 10,
                                leftIcon: const Icon(
                                    Icons.document_scanner_outlined,
                                    color: Colors.white),
                                header: const Text('Data Dokumen'),
                                content: Container(
                                  height: 300,
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 18),
                                                        child: Image.network(
                                                            "https://asset.smartrans.id/uploads/${newListDokumenDriver[index].fotoDokumen.toString()}"),
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
                                ),
                              )
                            ]),
                        Accordion(
                            headerBorderColor: Colors.blueGrey,
                            headerBorderColorOpened: Colors.transparent,
                            // headerBorderWidth: 1,
                            headerBackgroundColorOpened: Colors.cyanAccent,
                            contentBackgroundColor: Colors.white,
                            contentBorderColor: Colors.cyanAccent,
                            contentBorderWidth: 3,
                            contentHorizontalPadding: 20,
                            scaleWhenAnimating: true,
                            openAndCloseAnimation: true,
                            headerPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 15),
                            sectionOpeningHapticFeedback:
                                SectionHapticFeedback.medium,
                            sectionClosingHapticFeedback:
                                SectionHapticFeedback.light,
                            children: [
                              AccordionSection(
                                isOpen: false,
                                contentVerticalPadding: 10,
                                leftIcon: const Icon(
                                    Icons.directions_car_filled,
                                    color: Colors.white),
                                header: const Text('Data Kendaraan'),
                                content: Container(
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
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ]),
                        MaterialButton(
                            shape: const StadiumBorder(),
                            color: Colors.blueAccent,
                            minWidth: double.infinity,
                            child: Text("Simpan perubahan"),
                            onPressed: () async {
                              print(phoneController.text);

                              // Convert List<Map<String, dynamic>> to List<NotifListJob>
                              /* List<DokumenDriver> decodedJobList =
                                  decode.map((map) => DokumenDriver(
                                        nid: map['nid'],
                                        jenisDokumen: map['jenis_dokumen'],
                                        fotoDokumen: map['foto_dokumen'],
                                        datevalid: map['datevalid'],
                                        keteranganDokumen:
                                            map['keterangan_dokumen'],
                                        status: map['status'],
                                      )); */
                              /* final dataAccount = {
                      "mode": ["pelanggan"],
                      "phone": {
                        "phoneno": phoneController.text,
                        "countrycode": countryCode,
                        "verified_wa": "0",
                        "verified_sms": "0"
                      },
                      "username": widget.userModel.email,
                      "foto_akun":
                          "https://lh3.googleusercontent.com/a/ACg8ocKKzKel6U90qGca3UABAvNRkXJ_SibbN_hN_3omhloz2w",
                      "active_mode": "pelanggan",
                      "status_akun": 1,
                      "tanggal_lahir": dateBirthController.text
                    }; */
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
                              /*  final dataAccount =
                                  "{\"mode\": [\"pelanggan\"], \"phone\": {\"phoneno\": \"${phoneController.text}\", \"countrycode\": \"${countryCode}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${widget.userModel.email}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"pelanggan\", \"status_akun\": 1, \"tanggal_lahir\": \"${dateBirthController.text}\"}";
                              final userData = {
                                "id": widget.userModel.id,
                                "uid": widget.userModel.uid,
                                "email": widget.userModel.email,
                                "token": widget.userModel.token,
                                "data_account": dataAccount,
                                "rating": widget.userModel.rating,
                                "data_driver": widget.userModel.dataDriver,
                                "location": widget.userModel.location,
                                "created": widget.userModel.created,
                                "deposit": widget.userModel.deposit,
                                "transaction": widget.userModel.transaction,
                                "point": widget.userModel.point
                              };
                              LoginRepo().updateUser(userData);
                              Future.delayed(Duration(seconds: 4), () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    text: 'Data berhasil di edit',
                                    autoCloseDuration: Duration(seconds: 2));
                              }); */
                            })
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
