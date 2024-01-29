import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/model/fitur.dart';
import 'package:signgoogle/screen/passenger/choose_driver.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

import 'dart:convert';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';
import 'package:signgoogle/utils/mapbox.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter_map_directions/flutter_map_directions.dart'
    as flutterMapDirection;
import 'package:latlong2/latlong.dart';

class PassengerRide extends StatefulWidget {
  //PassengerRide({Key? key, required this.getContecxt, required this.getAuth})
  //    : super(key: key);
  PassengerRide({Key? key, required this.user}) : super(key: key);
  GoogleSignInAccount? user;
  @override
  State<PassengerRide> createState() => _PassengerRideState();
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onValueChanged;
  final VoidCallback onDelete;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.onValueChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  List<Map<String, dynamic>> _suggestions = [];
  bool focusField = false;
  late FocusNode _focusNode;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);

    //_focusNode = FocusNode();
  }

  void _onTextChanged() {
    final query = widget.controller.text;
    if (query.isNotEmpty) {
      _fetchLocations(query);
    } else {
      setState(() {
        _suggestions.clear();
      });
    }
  }

  Future<void> _fetchLocations(String query) async {
    // Replace 'YOUR_API_ENDPOINT' with your actual API endpoint
    var apiUrl =
        Uri.parse('https://api.smartrans.id/root/api/map/poi?search=$query');

    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        //setState(() {
        // Parse the response body
        var data = json.decode(response.body);
        _suggestions = List<Map<String, dynamic>>.from(data['items']);
        //});
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<List<String>> _fetchSuggestions(String query) async {
    var apiUrl =
        Uri.parse('https://api.smartrans.id/root/api/map/poi?search=$query');
    //await Future.delayed(Duration(milliseconds: 750));
    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        if (response == null || response.body.isEmpty) {
          return [];
        }
        var data = json.decode(response.body);
        List<Map<String, dynamic>> suggestions =
            List<Map<String, dynamic>>.from(data['items']);

        // Extract the strings from the suggestions and return as a list
        List<String> stringSuggestions = suggestions
            .map((item) => item['address']['label'] as String)
            .toList();
        //print(suggestions);
        return stringSuggestions;
      } else {
        List<String> nullList = [''];
        return nullList;
        //throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
      List<String> nullList = [''];
      return nullList;
    }
  }

  void _findFromSuggestions(String query) async {
    var apiUrl =
        Uri.parse('https://api.smartrans.id/root/api/map/poi?search=$query');
    //await Future.delayed(Duration(milliseconds: 750));
    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        if (response == null || response.body.isEmpty) {
          print("data kosong");
        }
        var data = json.decode(response.body);
        List<Map<String, dynamic>> suggestions =
            List<Map<String, dynamic>>.from(data['items']);
        suggestions
            .firstWhere((element) => element['address']['label'] == query);
        print(suggestions[0]['position']['lat']);
        print(suggestions[0]['position']['lng']);
      } else {
        //throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
      List<String> nullList = [''];
    }
  }

  void showOtherBS(BuildContext context) {
    showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 1,
      context: context,
      isSafeArea: false,
      bottomSheetColor: Colors.transparent,
      builder: (context, controller, offset) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Column(
            children: [
              Container(
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                child: EasyAutocomplete(
                  autofocus: true,
                  controller: widget.controller,
                  asyncSuggestions: (searchValue) async =>
                      _fetchSuggestions(searchValue),
                  //onChanged: (value) => print(value),
                  onSubmitted: (value) async {
                    widget.controller.text = value;
                    textController.text = value;
                    _findFromSuggestions(value);
                    _suggestions.clear();
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      useRootScaffold: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _suggestions.clear();
          _focusNode.unfocus(); // Remove focus from the text field
        });
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Lokasi jemput"),
                      controller: textController,
                      readOnly: true,
                      onTap: () {
                        // showAlert(context);
                        showOtherBS(context);
                      }),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.dispose();
    textController.dispose();
    super.dispose();
  }
}

class _PassengerRideState extends State<PassengerRide> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final List<CustomTextField> _textFields = [];
  List<String> _textValues = [];
  //final LatLng _center = const LatLng(45.521563, -122.677433);
  //late GoogleMapsPlaces _places;
  num lat = 0;
  num lng = 0;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  double? pickLat, pickLng, destLat, destLng;
  final List<Map<String, dynamic>> _suggestions = [];
  bool visibleAutocomplete = false;
  var resRoutes;
  List<flutterMapDirection.LatLng> directionDestLatLngs = [];
  List<LatLng> dataLatLngs = [];
  bool catchData = false;
  bool fromLocation = false;
  late bool serviceEnabled;
  late LocationPermission permission;
  String area = "";
  @override
  void initState() {
    super.initState();
    //getCurrentUser();
    _getCurrentLocation();
    print("passenger");
    print(widget.user);
  }

/* 
  Future<void> getCurrentUser() async {
    final user = await _googleSignIn.signIn();
    print("passenger");
    print(user);
  } */
  Future<List<String>> _fetchSuggestions(String query) async {
    var apiUrl =
        Uri.parse('https://api.smartrans.id/root/api/map/poi?search=$query');
    //await Future.delayed(Duration(milliseconds: 750));
    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        if (response == null || response.body.isEmpty) {
          return [];
        }
        var data = json.decode(response.body);
        List<Map<String, dynamic>> suggestions =
            List<Map<String, dynamic>>.from(data['items']);

        // Extract the strings from the suggestions and return as a list
        List<String> stringSuggestions = suggestions
            .map((item) => item['address']['label'] as String)
            .toList();
        //print(suggestions);
        return stringSuggestions;
      } else {
        List<String> nullList = [''];
        return nullList;
        //throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
      List<String> nullList = [''];
      return nullList;
    }
  }

  void _findPickupLatLng(String query) async {
    var apiUrl =
        Uri.parse('https://api.smartrans.id/root/api/map/poi?search=$query');
    //await Future.delayed(Duration(milliseconds: 750));
    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        if (response == null || response.body.isEmpty) {
          print("data kosong");
        }
        var data = json.decode(response.body);
        List<Map<String, dynamic>> suggestions =
            List<Map<String, dynamic>>.from(data['items']);
        suggestions
            .firstWhere((element) => element['address']['label'] == query);
        pickLat = suggestions[0]['position']['lat'];
        pickLng = suggestions[0]['position']['lng'];
      } else {
        //throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
      List<String> nullList = [''];
    }
  }

  void _findDestLatLng(String query) async {
    var apiUrl =
        Uri.parse('https://api.smartrans.id/root/api/map/poi?search=$query');
    //await Future.delayed(Duration(milliseconds: 750));
    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        if (response == null || response.body.isEmpty) {
          print("data kosong");
        }
        var data = json.decode(response.body);
        List<Map<String, dynamic>> suggestions =
            List<Map<String, dynamic>>.from(data['items']);
        suggestions
            .firstWhere((element) => element['address']['label'] == query);
        destLat = suggestions[0]['position']['lat'];
        destLng = suggestions[0]['position']['lng'];
      } else {
        //throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
      List<String> nullList = [''];
    }
  }

  void _collectValues() async {
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        !serviceEnabled) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Harap aktifkan lokasi terlebih dahulu"),
              actions: [
                MaterialButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ],
            );
          });
    } else {
      setState(() {
        catchData = true;
      });
      //print(_textFields.length);
      _textValues.clear(); // Clear the existing values before collecting again
      directionDestLatLngs.clear();
      directionDestLatLngs.add(
          flutterMapDirection.LatLng(pickLat!.toDouble(), pickLng!.toDouble()));
      directionDestLatLngs.add(
          flutterMapDirection.LatLng(destLat!.toDouble(), destLng!.toDouble()));
      if (_textFields.length != 0) {
        _textValues =
            _textFields.map((textField) => textField.controller.text).toList();
        _textValues.removeWhere((value) => value.isEmpty);

        for (int i = 0; i <= _textValues.length - 1; i++) {
          var apiUrl = Uri.parse(
              "https://api.smartrans.id/root/api/map/poi?search=${_textValues[i]}");
          var response = await http.get(apiUrl);
          try {
            if (response.statusCode == 200) {
              double otherDestLat =
                  json.decode(response.body)["items"][0]["position"]["lat"];
              double otherDestLng =
                  json.decode(response.body)["items"][0]["position"]["lng"];
              dataLatLngs.add(LatLng(otherDestLat, otherDestLng));
              directionDestLatLngs
                  .add(flutterMapDirection.LatLng(otherDestLat, otherDestLng));
              //});
            }
          } catch (e) {}
        }

        if ((_textValues.length + directionDestLatLngs.length - 1) ==
            directionDestLatLngs.length) {
          //print("goooooo");
          /*  await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChooseDriver(
                      dataLatLng: dataLatLngs,
                      directionLatLng: directionDestLatLngs))); */
          getScheduleCar(directionDestLatLngs, dataLatLngs);
          setState(() {
            catchData = false;
          });
        }
      } else {
        //print("goooooo");
        /* await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChooseDriver(
                    dataLatLng: dataLatLngs,
                    directionLatLng: directionDestLatLngs))); */
        getScheduleCar(directionDestLatLngs, dataLatLngs);
        setState(() {
          catchData = false;
        });
      }
    }
  }

  Future<void> getScheduleCar(
      List<flutterMapDirection.LatLng> directionDestLatLngs,
      List<LatLng> dataLatLngs) async {
    /* double getDisatance = Geolocator.distanceBetween(
        directionDestLatLngs.first.latitude.toDouble(),
        directionDestLatLngs.first.longitude.toDouble(),
        directionDestLatLngs.last.latitude.toDouble(),
        directionDestLatLngs.last.longitude.toDouble()); */
    Uri getTrafficeUrl = Uri.parse(
        "https://api.mapbox.com/directions/v5/mapbox/driving/${directionDestLatLngs.first.longitude}%2C${directionDestLatLngs.first.latitude}%3B${directionDestLatLngs.last.longitude}%2C${directionDestLatLngs.last.latitude}?alternatives=true&geometries=geojson&language=en&overview=full&steps=true&access_token=${accessTokenMapBox}");
    var getTraffice = await http.get(getTrafficeUrl);
    /* print(jsonEncode(_pickupController.text));
    print(jsonEncode(_destinationController.text));
    print(jsonEncode(_textValues)); */
    List<String> locations = [];
    locations.add(_pickupController.text);
    locations.add(_destinationController.text);
    if (_textValues.length != 0) {
      locations.addAll(_textValues);
    }

    print(jsonEncode(locations));
    print(jsonDecode(getTraffice.body)["routes"][0]["duration"]);
    print(jsonDecode(getTraffice.body)["routes"][0]["legs"][0]["steps"][0]
        ["intersections"][0]["bearings"][0]);
    String bearing = jsonDecode(getTraffice.body)["routes"][0]["legs"][0]
            ["steps"][0]["intersections"][0]["bearings"][0]
        .toString();
    String distance =
        jsonDecode(getTraffice.body)["routes"][0]["distance"].toString();
    String duration =
        jsonDecode(getTraffice.body)["routes"][0]["duration"].toString();
    var apiUrl = Uri.parse("${ApiNetwork().baseUrl}${To().price}");
    var dataBody = {
      "service": "ride",
      "qty": "${(double.parse(distance) / 1000).toStringAsFixed(2)}",
      "area": "${area}"
    };
    /* String username = 'base64';
    String password = 'email';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password')); */
    var response = await http.post(apiUrl,
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': "application/json; charset=UTF-8",
        },
        body: json.encode(dataBody));
    List<dynamic> conversions = json.decode(response.body)["data"]["fitur"];
    print(conversions.length);

    List<Feature> features = conversions.map((item) {
      if (item is Map<String, dynamic>) {
        return Feature.fromJson(item);
      } else {
        print("no data list");
        // Handle unexpected data or return a default Feature instance
        return Feature.fromJson({});
      }
    }).toList();
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChooseDriver(
                locations: locations,
                duration: duration,
                bearing: bearing,
                user: widget.user,
                directionLatLng: directionDestLatLngs,
                features: features,
                distance: (double.parse(duration) / 1000)
                    .toStringAsFixed(2)
                    .toString())));
    /* for (int i = 0; i <= features.length - 1; i++) {
        print(json.decode(response.body)["data"]["fitur"][i]["fitur"]);
      } */
    //print(features.length);
  }

  void _addTextField() {
    TextEditingController controller = TextEditingController();
    if (_textFields.length == 4) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 45,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Maksimal 4 tujuan tambahan"),
                  ],
                ),
              ),
            );
          });
    } else {
      _textFields.add(CustomTextField(
        controller: controller,
        onValueChanged: (value) {
          _fetchSuggestions(value);
        },
        onDelete: () => _removeTextField(controller),
      ));
    }
    setState(() {});
  }

  void _removeTextField(TextEditingController controller) {
    _textFields.removeWhere((textField) => textField.controller == controller);
    setState(() {});
  }

  Widget pickUpPop() {
    return Container(
      child: EasyAutocomplete(
        controller: _pickupController,
        asyncSuggestions: (searchValue) async => _fetchSuggestions(searchValue),
        //onChanged: (value) => print(value),
        onSubmitted: (value) async {
          _pickupController.text = value;

          _findPickupLatLng(value);
        },
      ),
    );
  }

  Future<void> showAlert(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 200,
              width: 200,
            ),
          );
        });
  }

  void showPickUpBS(BuildContext context) {
    showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 1,
      context: context,
      isSafeArea: false,
      bottomSheetColor: Colors.transparent,
      builder: (context, controller, offset) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Column(
            children: [
              Container(
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                child: EasyAutocomplete(
                  autofocus: true,
                  asyncSuggestions: (searchValue) async =>
                      _fetchSuggestions(searchValue),
                  onChanged: (value) => print(value),
                  onSubmitted: (value) async {
                    _pickupController.text = value;
                    _findPickupLatLng(value);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              /* Container(
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChooseMapMember()));
                    },
                    icon: Icon(Icons.map)),
              ), */
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      useRootScaffold: false,
    );
  }

  void showDestinationBS(BuildContext context) {
    showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 1,
      context: context,
      isSafeArea: false,
      bottomSheetColor: Colors.transparent,
      builder: (context, controller, offset) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Column(
            children: [
              Container(
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                child: EasyAutocomplete(
                  autofocus: true,
                  asyncSuggestions: (searchValue) async =>
                      _fetchSuggestions(searchValue),
                  onChanged: (value) => print(value),
                  onSubmitted: (value) async {
                    _destinationController.text = value;
                    _findDestLatLng(value);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              /* Container(
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChooseMapMember()));
                    },
                    icon: Icon(Icons.map)),
              ), */
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      useRootScaffold: false,
    );
  }

  void showDrivers(BuildContext context) {
    showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 1,
      context: context,
      isSafeArea: false,
      bottomSheetColor: Colors.transparent,
      builder: (context, controller, offset) {
        return Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Saran pengemudi",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 450,
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nyaman",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text("Best Save",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Rp. 25000",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                      SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {},
                                        child: Card(
                                          elevation: 2,
                                          color: Colors.orange,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Nego",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.alarm),
                                      SizedBox(width: 5),
                                      Text(
                                        "1-10 menit",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Image.asset(
                              "images/juberRides/juber_bike.png",
                              height: 90,
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Smart Trans XL",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text("1-6 seats",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Rp. 25000",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.alarm),
                                      SizedBox(width: 5),
                                      Text(
                                        "1-10 menit",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Image.asset(
                              "images/juberRides/juber_car.png",
                              height: 70,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.money),
                        Text("Cash Payment"),
                        Icon(Icons.chevron_right)
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Text("Promo"),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Icon(Icons.calendar_month),
                      ),
                    ],
                  )
                ],
              ),
              MaterialButton(
                minWidth: double.infinity,
                onPressed: () {},
                color: primaryColor,
                child: Text(
                  "Pesan Sekarang",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      useRootScaffold: false,
    );
  }

  Future<void> _showLocationServiceDialog() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Lokasi Belum Diizinkan"),
          content: Text("Aktifkan lokasi dulu yaa..."),
          actions: <Widget>[
            MaterialButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    print(LocationPermission.values);
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await _showLocationServiceDialog();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        await _showLocationServiceDialog();
      }
    }
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //final location = await location2.getLocation();

    var apiUrl = Uri.parse(
        "https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?language=id&access_token=sk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG5tMGtsYzBwN2UybW9icGk2ZzY5emcifQ.UneRCntojkFKhKCdEQKosg");

    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          fromLocation = true;
          area = data["features"][0]["context"][3]["text_id"];
        });
        _pickupController.text = data["features"][0]["place_name"];

        print(data["features"][0]["context"][3]["text_id"]);
        // print(data["place_name"]);
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
    }
    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      pickLat = position.latitude;
      pickLng = position.longitude;
      print("latlng : ${lat}, ${lng}");
    });
  }

  @override
  Widget build(BuildContext context) {
    //final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    var width = MediaQuery.of(context).size.width;
    //return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _suggestions.clear();
          FocusScope.of(context).unfocus();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
        ),
        body: SingleChildScrollView(
            child: Container(
          child: Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    )),

                    ///padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 18, right: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 15,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 20),
                                  fromLocation
                                      ? Container(
                                          height: 50,
                                          width: width * 0.75,
                                          child: TextField(
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Lokasi jemput"),
                                              controller: _pickupController,
                                              readOnly: true,
                                              onTap: () {
                                                // showAlert(context);
                                                showPickUpBS(context);
                                              }),
                                        )
                                      : Container(
                                          height: 25,
                                          width: 25,
                                          padding: EdgeInsets.all(5),
                                          child: CircularProgressIndicator(
                                            color: Colors.green,
                                          ),
                                        )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 18, right: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 15,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 20),
                                  Container(
                                    height: 50,
                                    width: width * 0.65,
                                    child: TextField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Tujuan anda"),
                                        controller: _destinationController,
                                        readOnly: true,
                                        onTap: () {
                                          // showAlert(context);
                                          showDestinationBS(context);
                                        }),
                                  ),
                                  Container(
                                    height: 45,
                                    margin:
                                        EdgeInsets.only(bottom: 10, left: 15),
                                    child: ClipOval(
                                      child: Card(
                                        color: Colors.orange[200],
                                        elevation: 4,
                                        shape:
                                            CircleBorder(), // To ensure the Card is circular
                                        child: IconButton(
                                          onPressed: () {
                                            _addTextField();
                                          },
                                          icon: Icon(Icons.add),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: visibleAutocomplete,
                          child: Container(
                            height: 100,
                            child: Expanded(
                              child: ListView.builder(
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_suggestions[index]['title']),
                                    subtitle: Text(_suggestions[index]
                                        ['address']['label']),
                                    onTap: () {
                                      // Handle the selected location
                                      // Set the selected suggestion into the corresponding TextField
                                      /* String selectedTitle = _suggestions[index]['title'];
                                      int textFieldIndex = /* Determine the index of the corresponding TextField */;
                                      _textFields[textFieldIndex].controller.text = selectedTitle; */
                                      setState(() {
                                        visibleAutocomplete = false;
                                        _suggestions.clear();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: _textFields,
                        ),
                      ],
                    )),
              ),
              SizedBox(
                height: 25,
              ),
              Material(
                elevation: 2,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 12, bottom: 12),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Container(
                              color: Colors.grey.withOpacity(0.2),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.home,
                                color: Colors.grey,
                                size: 25,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Home",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 12, bottom: 12),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Container(
                              color: Colors.grey.withOpacity(0.2),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.work,
                                color: Colors.grey,
                                size: 25,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Work",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Card(
                elevation: 2,
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Perjalanan sebelumnya",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.pin_drop_outlined,
                              color: primaryColor,
                              size: 35,
                            ),
                            title: Text("Tunjungan Surabaya"),
                            subtitle: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: Text(
                                    "Jl. Embong malang no 52 Tunjungan Surabaya")),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.pin_drop_outlined,
                              color: primaryColor,
                              size: 35,
                            ),
                            title: Text("Bungurasih Waru Sidoarjo"),
                            subtitle: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child:
                                    Text("Jl. Bungurasu waru no 12 Sidoarjo")),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.pin_drop_outlined,
                              color: primaryColor,
                              size: 35,
                            ),
                            title: Text("Cito Sidoarjo"),
                            subtitle: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: Text("Jl. A. Yani no 120 Sidoarjo")),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.pin_drop_outlined,
                              color: primaryColor,
                              size: 35,
                            ),
                            title: Text("Tunjungan Surabaya"),
                            subtitle: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: Text(
                                    "Jl. Embong malang no 52 Tunjungan Surabaya")),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )),
        bottomSheet: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: primaryColor,
              ),
              margin: EdgeInsets.only(bottom: 20),
              child: MaterialButton(
                onPressed: () async {
                  _collectValues();

                  /* await Future.delayed(const Duration(seconds: 3), () {
                    // if (catchData) {
                    print("data : ${directionDestLatLngs.length}");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChooseDriver(
                                dataLatLng: dataLatLngs,
                                directionLatLng: directionDestLatLngs)));
                    setState(() {
                      catchData = false;
                    });
                  }); */
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: catchData
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ))
                      : Text(
                          "Confirm",
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // });
  }
}
