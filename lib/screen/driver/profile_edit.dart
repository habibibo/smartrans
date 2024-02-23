import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_country_code_picker/flutter_country_code_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:mime/mime.dart';
import 'package:phonecodes/phonecodes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
//import 'package:signgoogle/bloc/driver/passenger_bloc.dart';
import 'package:signgoogle/component/popup_loading.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/dokumen_driver.dart';
import 'package:signgoogle/model/kendaraan_driver.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/passenger.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/screen/driver/home.dart';
import 'package:signgoogle/screen/driver/profile.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';

class ProfileEdit extends StatelessWidget {
  UserModel userModel;
  ProfileEdit({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileEditScreen(userModel: userModel),
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  UserModel userModel;
  ProfileEditScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  TextEditingController dateBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

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

  String? phoneInit = "";
  String countryCode = "";
  String foto_akun = "";
  String dateBirth = "";
  List<DokumenDriver> driverDocuments = [];
  List<KendaraanDriver> driverVehicles = [];
  late File _image;
  late File _image2;

  var jsonUserModel = "";
  @override
  void initState() {
    super.initState();
    //BlocProvider.of<PassengerBloc>(context).getUser();
    jsonUserModel = jsonEncode(widget.userModel.toJson());
    widget.userModel = widget.userModel;
    jsonUserModel = jsonEncode(widget.userModel.toJson());
    print(jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
        ["countrycode"]);
    usernameController.text =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["username"];
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
    if (widget.userModel.dataDriver != null) {
      var decode = jsonDecode(widget.userModel.dataDriver.toString());
      List<dynamic> jsonDokumen = json.decode(decode["dokumen_driver"]);
      List<dynamic> jsonKendaraan = json.decode(decode["kendaraan_driver"]);
      // Convert List<Map<String, dynamic>> to List<DokumenDriver>
      driverDocuments =
          jsonDokumen.map((json) => DokumenDriver.fromJson(json)).toList();
      driverVehicles =
          jsonKendaraan.map((json) => KendaraanDriver.fromJson(json)).toList();
    }
    //BlocProvider.of<PassengerBloc>(context).getUser();

    // passengerBloc.add(PassengerStart());

    /* var jsonUserModel = jsonEncode(widget.userModel.toJson());
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
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"]; */
    //print(jsonDecode(widget.userModel.dataAccount.toString())["phone"]
    //    ["phoneno"]);
    print(foto_akun);
  }

  showText(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            width: double.infinity,
            color: Colors.grey,
            height: 100,
            child: TextField(
              autofocus: true,
              onSubmitted: (value) {
                phoneController.text = value;

                Navigator.pop(context);
              },
            ),
          );
        });
  }

  Future<UserModel> getProfile() async {
    SharedPreferences uid = await SharedPreferences.getInstance();
    final data = {"uid": uid.getString("uid").toString()};
    final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
    var response = await http.post(
      getUserUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      body: jsonEncode(data),
    );
    return UserModel.fromJson(jsonDecode(response.body)["data"]);
  }

  void deleteDataDriver(int index, String type) {
    if (type == "kendaraan") {
      setState(() {
        driverVehicles.remove(driverVehicles[index]);
        print(driverVehicles.length);
      });
    } else {
      setState(() {
        driverDocuments.remove(driverDocuments[index]);
        print(driverDocuments.length);
      });
    }
  }

  void addNewDocument() async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(15),
            height: 400,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
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
                            type: SelectFormFieldType
                                .dropdown, // or can be dialog
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
                            onChanged: (val) =>
                                jenis_dokumenController.text = val,
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
                Container(
                  child: MaterialButton(
                      shape: StadiumBorder(),
                      color: primaryColor,
                      child: Text("Tambah"),
                      onPressed: () async {
                        if (nidController.text.isEmpty ||
                            uploadDokumenController.text.isEmpty ||
                            dateBirthController.text.isEmpty) {
                          QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              text: "Harap lengkapi field");
                        } else {
                          if (jenis_dokumenController.text.isEmpty) {
                            jenis_dokumenController.text = "KTP";
                          }
                          if (driverDocuments
                              .where((element) =>
                                  element.jenisDokumen.toString() ==
                                  jenis_dokumenController.text)
                              .isEmpty) {
                            PopupLoading();

                            updloadFiles(_image, "dokumen");
                          } else {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                text: "Jenis dokumen pernah ditambahkan");
                          }
                        }

                        //updloadFiles(_image, "dokumen");
                        /* setState(() {
                      newListDokumenDriver.add(DokumenDriver(
                          nid: nidController.text,
                          jenisDokumen: jenis_dokumenController.text,
                          fotoDokumen: uploadDokumenController.text,
                          datevalid: datevalidController.text,
                          keteranganDokumen: "On Review",
                          status: 0));
                      newFileDokumen.add(_image);
                    }); */
                      }),
                ),
              ],
            ),
          );
        });
  }

  void addNewVehicle() async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(15),
            height: 400,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      child: TextField(
                    controller: jenisController,
                    decoration: InputDecoration(
                      labelText: "Jenis  (Avanza / Mobilio, etc)",
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
                    child: MaterialButton(
                        shape: StadiumBorder(),
                        color: Colors.blue,
                        child: Text("Tambah"),
                        onPressed: () async {
                          if (merkController.text.isEmpty ||
                              jenisController.text.isEmpty ||
                              uploadKendaraanController.text.isEmpty ||
                              platNoController.text.isEmpty) {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.info,
                                text: "Harap lengkapi field");
                          } else {
                            if (driverVehicles
                                .where((element) =>
                                    element.platNo.toString() ==
                                    jenis_dokumenController.text)
                                .isEmpty) {
                              PopupLoading();
                              updloadFiles(_image2, "kendaraan");
                            } else {
                              QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.info,
                                  text: "Plat nomor tidak boleh sama");
                            }
                          }
                          //print(widget.userModel.dataDriver);
                          //if (widget.userModel.dataDriver == null) {

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
                          //   }
                        }),
                  ),
                ]),
          );
        });
  }

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
        //Navigator.of(context, rootNavigator: true).pop();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            autoCloseDuration: Duration(seconds: 2));
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          print("dokumen");
          driverDocuments.add(DokumenDriver(
              nid: nidController.text,
              jenisDokumen: jenis_dokumenController.text,
              fotoDokumen: jsonDecode(streamREesponse.body)["filename"],
              datevalid: datevalidController.text,
              keteranganDokumen: "On Review",
              status: 0));

          nidController.text = "";
          jenis_dokumenController.text = "";
          datevalidController.text = "";
          uploadDokumenController.text = "";
          //newFileDokumen.add(_image);
        });
      }
      if (type == "kendaraan") {
        // Navigator.of(context, rootNavigator: true).pop();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            autoCloseDuration: Duration(seconds: 2));
        print(jsonDecode(streamREesponse.body)["filename"]);
        setState(() {
          print("kendaraan");
          driverVehicles.add(KendaraanDriver(
              jenis: jenisController.text,
              merk: merkController.text,
              platNo: platNoController.text,
              fotoKendaraan: jsonDecode(streamREesponse.body)["filename"],
              keteranganKendaraan: "On Review",
              status: 0));
          jenisController.text = "";
          merkController.text = "";
          platNoController.text = "";
          uploadKendaraanController.text = "";
          //newFileKendaraan.add(_image2);
          /* newListKendaraanDriver[index].fotoKendaraan =
              jsonDecode(streamREesponse.body)["filename"];
          print(newListKendaraanDriver[index].fotoKendaraan); */
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /* BlocBuilder<PassengerBloc, PassengerState>(
      builder: (context, state) {
        if (state is PassengerLoadingState) {
          return PopupLoading();
        }
        if (state is GetUserModel) {
          
        } */

    return Scaffold(
      body: Container(
          margin: EdgeInsets.only(top: 30, left: 5, right: 5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: primaryColor),
                  child: Card(
                    color: primaryColor,
                    child: Container(
                      padding: EdgeInsets.only(
                        right: 15,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Column(
                        children: [
                          Container(
                              child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(50)),
                              //child: Icon(Icons.person),
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DriverHome(
                                                  userModel: widget.userModel,
                                                  isDriver: true,
                                                )));
                                  },
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 28,
                                  )),
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
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Data pribadi",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_2),
                                  labelText: "Nama"),
                            ),
                          ),
                          Container(
                            child: TextField(
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_month),
                                  labelText: "Tanggal Lahir"),
                              controller: dateBirthController,
                              readOnly: true,
                              onTap: () async {
                                DateTime? dateTime = await showDatePicker(
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    onDatePickerModeChange: (value) {
                                      // setState(() {
                                      dateBirthController.text =
                                          value.toString();
                                      // });
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
                                  // setState(() {
                                  dateBirthController.text = formattedDate;
                                  //   });
                                }
                              },
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Container(
                                  width: 120,
                                  child: CountryCodePicker(
                                    onChanged: (value) {
                                      countryCode = value.dialCode.toString();
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: countryCode == ""
                                        ? "ID"
                                        : Countries.findByDialCode(jsonDecode(
                                                    jsonDecode(jsonUserModel)[
                                                        "data_account"])[
                                                "phone"]["countrycode"])
                                            .first
                                            .code,
                                    //favorite: const ['+62', 'ID'],
                                    // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                                    flagDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Berkas Dokumen",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Material(
                                          color: primaryColor,
                                          shape: StadiumBorder(),
                                          elevation: 5,
                                          child: IconButton(
                                              onPressed: () {
                                                addNewDocument();
                                              },
                                              icon: Icon(
                                                  Icons.add_card_outlined)),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 280,
                                      width: double.infinity,
                                      child: ListView.builder(
                                          itemCount: driverDocuments.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Card(
                                                elevation: 2,
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 200,
                                                        width: double.infinity,
                                                        child: Image.network(
                                                            fit: BoxFit.fill,
                                                            "https://asset.smartrans.id/uploads/${driverDocuments[index].fotoDokumen.toString()}"),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                            driverDocuments[
                                                                    index]
                                                                .jenisDokumen
                                                                .toString()),
                                                        subtitle: Container(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(driverDocuments[
                                                                      index]
                                                                  .nid
                                                                  .toString()),
                                                              Text(
                                                                "Expired at ${driverDocuments[index].datevalid.toString()}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .orange,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                driverDocuments[
                                                                        index]
                                                                    .keteranganDokumen
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: driverDocuments[index].keteranganDokumen.toString() ==
                                                                            "On Review"
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        /* leading: Container(
                                                          width: 140,
                                                          height: 140,
                                                          child: Image.network(
                                                              fit: BoxFit.fill,
                                                              "https://asset.smartrans.id/uploads/${driverDocuments[index].fotoDokumen.toString()}"),
                                                        ), */
                                                        trailing: Material(
                                                          color: Colors.white,
                                                          shape:
                                                              StadiumBorder(),
                                                          elevation: 5,
                                                          child: IconButton(
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
                                                                              EdgeInsets.all(15),
                                                                          margin:
                                                                              EdgeInsets.all(40),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                              color: Colors.white),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Text(
                                                                                "Apakah anda yakin ?",
                                                                                style: TextStyle(fontSize: 20),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                                Icons
                                                                    .delete_forever,
                                                                color:
                                                                    Colors.red,
                                                                size: 28,
                                                              )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Berkas Kendaraan",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Material(
                                          color: primaryColor,
                                          shape: StadiumBorder(),
                                          elevation: 5,
                                          child: IconButton(
                                              onPressed: () {
                                                addNewVehicle();
                                              },
                                              icon:
                                                  Icon(Icons.commute_outlined)),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 280,
                                      width: double.infinity,
                                      child: ListView.builder(
                                          itemCount: driverVehicles.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Card(
                                                elevation: 2,
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 200,
                                                        width: double.infinity,
                                                        child: Image.network(
                                                            fit: BoxFit.fill,
                                                            "https://asset.smartrans.id/uploads/${driverVehicles[index].fotoKendaraan.toString()}"),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                            driverVehicles[
                                                                    index]
                                                                .merk
                                                                .toString()),
                                                        subtitle: Container(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(driverVehicles[
                                                                      index]
                                                                  .jenis
                                                                  .toString()),
                                                              Text(driverVehicles[
                                                                      index]
                                                                  .platNo
                                                                  .toString()),
                                                              Text(
                                                                driverVehicles[
                                                                        index]
                                                                    .keteranganKendaraan
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: driverVehicles[index].keteranganKendaraan.toString() ==
                                                                            "On Review"
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        /* leading: Container(
                                                          width: 140,
                                                          height: 140,
                                                          child: Image.network(
                                                              fit: BoxFit.fill,
                                                              "https://asset.smartrans.id/uploads/${driverVehicles[index].fotoKendaraan.toString()}"),
                                                        ), */
                                                        trailing: Material(
                                                          elevation: 5,
                                                          shape:
                                                              StadiumBorder(),
                                                          color: Colors.white,
                                                          child: IconButton(
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
                                                                              EdgeInsets.all(15),
                                                                          margin:
                                                                              EdgeInsets.all(40),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                              color: Colors.white),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Text(
                                                                                "Apakah anda yakin ?",
                                                                                style: TextStyle(fontSize: 20),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                                color:
                                                                    Colors.red,
                                                                size: 28,
                                                              )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          MaterialButton(
                              shape: const StadiumBorder(),
                              color: Colors.blueAccent,
                              minWidth: double.infinity,
                              child: Text("Simpan perubahan"),
                              onPressed: () {
                                print(phoneController.text);
                                print(countryCode);
                                if (driverDocuments.isEmpty) {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      text:
                                          "Berkas dokumen driver tidak boleh kosong");
                                } else {
                                  if (driverVehicles.isEmpty) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        text:
                                            "Berkas kendaraan driver tidak boleh kosong");
                                  } else {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: (context),
                                        builder: (context) {
                                          return LogoandSpinner(
                                            imageAssets:
                                                'images/loadingsmartrans.png',
                                            reverse: false,
                                            arcColor: primaryColor,
                                            spinSpeed:
                                                Duration(milliseconds: 500),
                                          );
                                        });
                                    final dataDriver;
                                    if (widget.userModel.dataDriver == null) {
                                      dataDriver = {
                                        "keterangan_driver": "",
                                        "status_driver": 1,
                                        "dokumen_driver":
                                            jsonEncode(driverDocuments),
                                        "kendaraan_driver":
                                            jsonEncode(driverVehicles),
                                        "onoff": 1,
                                      };
                                    } else {
                                      var decodeDriver = jsonDecode(widget
                                          .userModel.dataDriver
                                          .toString());
                                      dataDriver = {
                                        "keterangan_driver":
                                            decodeDriver["keterangan_driver"],
                                        "status_driver": 1,
                                        "dokumen_driver":
                                            jsonEncode(driverDocuments),
                                        "kendaraan_driver":
                                            jsonEncode(driverVehicles),
                                        "onoff": 1,
                                      };
                                    }

                                    final dataAccount =
                                        "{\"mode\": [\"driver\"], \"phone\": {\"phoneno\": \"${phoneController.text}\", \"countrycode\": \"${countryCode.toString()}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${usernameController.text}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"driver\", \"status_akun\": 1, \"tanggal_lahir\": \"${dateBirthController.text}\"}";
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
                                      "transaction":
                                          widget.userModel.transaction,
                                      "point": widget.userModel.point
                                    };
                                    LoginRepo()
                                        .updateUser(userData)
                                        .then((value) {
                                      if (value["status"] == "ok") {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.success,
                                            text: 'Data berhasil di edit',
                                            autoCloseDuration:
                                                Duration(seconds: 2));
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DriverHome(
                                                      userModel:
                                                          widget.userModel,
                                                      isDriver: true,
                                                    )));
                                      } else {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            text: 'Data gagal disimpan',
                                            autoCloseDuration:
                                                Duration(seconds: 2));
                                      }
                                    });
                                  }
                                }

                                /* showDialog(
                                    barrierDismissible: false,
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
                                var decodeDriver = jsonDecode(
                                    widget.userModel.dataDriver.toString());
                                final dataDriver = {
                                  "keterangan_driver":
                                      decodeDriver["keterangan_driver"],
                                  "status_driver": 1,
                                  "dokumen_driver": jsonEncode(driverDocuments),
                                  "kendaraan_driver":
                                      jsonEncode(driverVehicles),
                                  "onoff": 1,
                                };
                                final dataAccount =
                                    "{\"mode\": [\"driver\"], \"phone\": {\"phoneno\": \"${phoneController.text}\", \"countrycode\": \"${countryCode.toString()}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${usernameController.text}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"driver\", \"status_akun\": 1, \"tanggal_lahir\": \"${dateBirthController.text}\"}";
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
                                LoginRepo().updateUser(userData).then((value) {
                                  if (value["status"] == "ok") {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        text: 'Data berhasil di edit',
                                        autoCloseDuration:
                                            Duration(seconds: 2));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DriverHome(
                                                  userModel: widget.userModel,
                                                  isDriver: true,
                                                )));
                                  } else {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();

                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        text: 'Data gagal disimpan',
                                        autoCloseDuration:
                                            Duration(seconds: 2));
                                  }
                                }); */
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
    //},
    //);
  }

  @override
  void dispose() {
    //PassengerBloc().close();
    phoneController.dispose();
    super.dispose();
  }
}
