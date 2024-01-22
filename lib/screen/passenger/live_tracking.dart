import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/model/driver_model.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_map_directions/flutter_map_directions.dart'
    as flutterMapDirection;
import 'package:latlong2/latlong.dart';
import 'package:signgoogle/main.dart';

/* void main() {
  List<flutterMapDirection.LatLng> listLatlng = [];
  DriverModel driverModel = DriverModel(
      id: 0,
      name: "",
      photoUrl: "",
      price: 0,
      latlng: [],
      car: "",
      nopol: "",
      distanceOrder: "",
      distanceDriver: "",
      arriveTime: "");
  GoogleSignInAccount? user;
  runApp(LiveTracking(driverModel: driverModel, user: user));
} */

class LiveTracking extends StatefulWidget {
  final DriverModel driverModel;
  GoogleSignInAccount? user;
  LiveTracking({Key? key, required this.driverModel, required this.user})
      : super(key: key);

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  late AuthRepository authRepository = AuthRepository();
  late GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<bool> getPassengerHome() async {
    //final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    //authBloc.add(GoingPassenger());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => getPassengerHome(),
        child: MaterialApp(
          home: BlocProvider(
            create: (context) => AuthBloc(
                authRepository: authRepository, navigatorKey: navigatorKey)
              ..add(AppStarted()),
            child: LiveTrackingScreen(
                driverModel: widget.driverModel, user: widget.user),
          ),
        ));
  }
}
/* 
class LiveTracking extends StatelessWidget {
  final DriverModel driverModel;
  GoogleSignInAccount? user;
  LiveTracking({Key? key, required this.driverModel, required this.user})
      : super(key: key);

  @override
  void initState() {}
  String test = "";

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository;
    final GlobalKey<NavigatorState> navigatorKey;
    return MaterialApp(
      home: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: authRepository, navigatorKey: navigatorKey)
              ..add(AppStarted()),
        child: LiveTrackingScreen(driverModel: driverModel, user: user),
      ),
    );
  }
} */

class LiveTrackingScreen extends StatefulWidget {
  LiveTrackingScreen({Key? key, required this.driverModel, required this.user})
      : super(key: key);
  final DriverModel driverModel;
  GoogleSignInAccount? user;
  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final BoxController boxController = BoxController();

  Widget bodyCollapsed() {
    return Stack(
      children: [
        Container(
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
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Detail Order",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        widget.driverModel.car == "SmartBike"
                            ? ClipOval(
                                child: Container(
                                    color: Colors.grey,
                                    padding: EdgeInsets.all(8),
                                    child:
                                        Icon(Icons.directions_bike_outlined)))
                            : Icon(Icons.directions_car_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(widget.driverModel.car == "SmartBike"
                                ? "VARIO"
                                : "AVANZA "),
                            Text(widget.driverModel.nopol),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Penjemputan"),
                      ],
                    ),
                    Row(
                      children: [Text("${widget.driverModel.arriveTime} mnt")],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Jarak tempuh"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("${widget.driverModel.distanceDriver} km")
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: List.generate(
                    450 ~/ 10,
                    (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0
                                ? Colors.transparent
                                : Colors.grey,
                            height: 2,
                          ),
                        )),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Perjalanan anda"),
                      ],
                    ),
                    Row(
                      children: [Text("15 mnt")],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Jarak tempuh"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("${widget.driverModel.distanceOrder} km")
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Biaya"),
                      ],
                    ),
                    Row(
                      children: [Text("Rp ${widget.driverModel.price}")],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showPanel(BuildContext context) {
    return Stack(
      children: [
        Container(
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
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Detail Order",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        widget.driverModel.car == "SmartBike"
                            ? ClipOval(
                                child: Container(
                                    color: Colors.grey,
                                    padding: EdgeInsets.all(8),
                                    child:
                                        Icon(Icons.directions_bike_outlined)))
                            : Icon(Icons.directions_car_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(widget.driverModel.car == "SmartBike"
                                ? "VARIO"
                                : "AVANZA "),
                            Text(widget.driverModel.nopol),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [Icon(Icons.alarm), Text("10 menit")],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> getPassengerHome(BuildContext context) async {
    Navigator.pop(context);
    Navigator.pop(context);
    //final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    //authBloc.add(GoingPassenger());
    /* await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PassengerHome(user: widget.user, isDriver: false))); */
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    /* return WillPopScope(
      onWillPop: () => getPassengerHome(context),
      child:  */
    //return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        return SlidingBox(
          controller: boxController,
          minHeight: 140,
          maxHeight: 270,
          //color: Theme.of(context).colorScheme.background,
          style: BoxStyle.sheet,
          backdrop: Backdrop(
            // overlay: true,
            appBar: BackdropAppBar(
                title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      //GoogleSignInAccount? user = widget.user;
                      //print("print");
                      //authBloc.add(GoingPassenger());
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PassengerHome(
                                    user: widget.user,
                                    isDriver: false,
                                  )));
                    },
                    icon: Icon(
                      Icons.arrow_circle_left,
                      size: 45,
                    ))
              ],
            )),
            color: Theme.of(context).colorScheme.background,
            body: FlutterMap(
              options: MapOptions(
                center: LatLng(widget.driverModel.latlng.first.latitude,
                    widget.driverModel.latlng.first.longitude),
                zoom: 12,
                //bounds: LatLngBounds()
              ),
              //mapController: _mapController,
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/bibohabib/clpqqrem1014q01o962k54da8/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG04MGVzdDA2MWUya3FtdDMxbDBuNDUifQ.ivQ5qmo7cPT4FaC6Q2aalQ",
                  additionalOptions: {
                    'accessToken':
                        'sk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG5tMGtsYzBwN2UybW9icGk2ZzY5emcifQ.UneRCntojkFKhKCdEQKosg',
                    'id': 'mapbox.streets',
                  },
                ),
              ],
            ),

            /* FlutterMap(
                options: MapOptions(
                  center: LatLng(widget.directionLatLng[0].latitude,
                      widget.directionLatLng[0].longitude),
                  zoom: 12,
                  //bounds: LatLngBounds()
                ),
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/bibohabib/clpqqrem1014q01o962k54da8/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG04MGVzdDA2MWUya3FtdDMxbDBuNDUifQ.ivQ5qmo7cPT4FaC6Q2aalQ",
                    additionalOptions: {
                      'accessToken':
                          'sk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG5tMGtsYzBwN2UybW9icGk2ZzY5emcifQ.UneRCntojkFKhKCdEQKosg',
                      'id': 'mapbox.streets',
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.directionLatLng[0].latitude,
                            widget.directionLatLng[0].longitude),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.directionLatLng.last.latitude,
                            widget.directionLatLng.last.longitude),
                        builder: (ctx) => Container(
                          margin: EdgeInsets.only(bottom: 12, left: 37),
                          child: Transform.rotate(
                            angle: 180 * pi / 180,
                            child: Icon(
                              Icons.water_drop,
                              color: Colors.red.shade500,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  flutterMapDirection.DirectionsLayer(
                    //coordinates: latlngs2,
                    coordinates: widget.directionLatLng,
                    color: Colors.blueAccent,
                    strokeWidth: 2,
                  ),
                ],
              )), */
          ),
          body: bodyCollapsed(),
          collapsed: true,
          collapsedBody: showPanel(context),
        );
      }),
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.only(left: 5, right: 5, top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                          padding: EdgeInsets.all(9),
                          color: Colors.grey,
                          child: Icon(
                            Icons.person_2_outlined,
                            size: 30,
                            color: Colors.white,
                          ))),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(widget.driverModel.name),
                      Icon(Icons.star_border_outlined)
                    ],
                  )
                ],
              ),
              ClipOval(
                clipBehavior: Clip.hardEdge,
                child: Container(
                  padding: EdgeInsets.all(2),
                  color: Colors.lightBlue,
                  child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 30,
                      )),
                ),
              )
            ],
          ),
        )
      ],
    );
    //});
    //);
  }
}
