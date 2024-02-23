import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong2/latlong.dart';
import 'package:marquee/marquee.dart';
import 'package:signgoogle/model/customer_transaction.dart';
import 'package:signgoogle/model/location.dart';
import 'package:signgoogle/model/notif/driver_bid.dart';
import 'package:signgoogle/model/pricing_detail.dart';
import 'package:signgoogle/model/transaction.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:signgoogle/utils/mapbox.dart';
import 'package:flutter_map_directions/flutter_map_directions.dart'
    as flutterMapDirection;

class LiveTracking extends StatefulWidget {
  Transaction transaction;
  PricingDetails pricingDetails;
  CustomerTransaction customerTransaction;
  DriverBid driverBid;
  List<Location> newLocation;
  String duration;
  String distance;

  LiveTracking({
    Key? key,
    required this.transaction,
    required this.pricingDetails,
    required this.customerTransaction,
    required this.driverBid,
    required this.newLocation,
    required this.duration,
    required this.distance,
  }) : super(key: key);

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  final BoxController boxController = BoxController();
  final TextEditingController textEditingController = TextEditingController();
  final List<flutterMapDirection.LatLng> directionLatLng = [];
  String statusDriver = "";
  @override
  void initState() {
    super.initState();
    //for (int i = 0; i <= widget.newLocation.length - 1; i++) {
    directionLatLng.add(flutterMapDirection.LatLng(
        double.parse(widget.newLocation[0].lat),
        double.parse(widget.newLocation[0].lng)));
    directionLatLng.add(flutterMapDirection.LatLng(
        double.parse(widget.driverBid.driverLatLng!.lat.toString()),
        double.parse(widget.driverBid.driverLatLng!.lng.toString())));
    //}
    statusDriver = "Sedang bersiap menjemput anda";
    textEditingController.addListener(() {
      boxController.setSearchBody(
          child: Center(
        child: Text(
          textEditingController.text != ""
              ? textEditingController.value.text
              : "Empty",
          style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground, fontSize: 20),
        ),
      ));
    });
    setState(() {});
  }

  _backdrop() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(double.parse(widget.newLocation[0].lat),
                double.parse(widget.newLocation[0].lng)),
            zoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/bibohabib/clpqqrem1014q01o962k54da8/tiles/256/{z}/{x}/{y}@2x?access_token=${accessTokenMapBox}",
              additionalOptions: {
                'accessToken': tokenMapbox,
                'id': 'mapbox.streets',
              },
            ),
            MarkerLayer(markers: [
              Marker(
                  point: LatLng(double.parse(widget.newLocation[0].lat),
                      double.parse(widget.newLocation[0].lng)),
                  builder: (ctx) => Container(
                        height: 400,
                        width: 200,
                        child: Column(
                          children: [
                            Text("Passenger"),
                            SizedBox(
                              height: 5,
                            ),
                            Icon(
                              Icons.location_pin,
                              color: Colors.redAccent,
                              size: 40.0,
                            ),
                          ],
                        ),
                      ),
                  height: 60),
              Marker(
                  point: LatLng(widget.driverBid.driverLatLng!.lat,
                      widget.driverBid.driverLatLng!.lng),
                  builder: (ctx) => Container(
                        height: 400,
                        width: 200,
                        child: Column(
                          children: [
                            Text("Driver"),
                            SizedBox(
                              height: 5,
                            ),
                            Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                              size: 40.0,
                            ),
                          ],
                        ),
                      ),
                  height: 60),
            ]),
            flutterMapDirection.DirectionsLayer(
              //coordinates: latlngs2,
              coordinates: directionLatLng,
              color: Colors.blueAccent,
              strokeWidth: 4,
            ),
          ],
        ),
      ],
    );
  }

  _body() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                    ),
                    child:
                        Image.network(widget.driverBid.fotoDriver.toString()),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 2),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        child: Text(
                          widget.driverBid.namaDriver.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        child: Text(
                          widget.driverBid.kendaraan.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ),
                    ],
                  )),
                  const Icon(
                    Icons.airport_shuttle_outlined,
                    color: Colors.greenAccent,
                    size: 40,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Card(
              elevation: 5,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Biaya dan Metode pembayaran",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Rp. ${widget.pricingDetails.price}"),
                    SizedBox(
                      height: 5,
                    ),
                    Text(widget.transaction.paymentmethod.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Card(
              elevation: 5,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tipe kendaraan",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(widget.transaction.fitur.toString()),
                    SizedBox(
                      height: 5,
                    ),
                    Text(widget.transaction.waktuPickup.toString())
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Card(
              elevation: 5,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lokasi dan tujuan penumpang",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //Text("${widget.distance} km"),
                    SizedBox(
                      height: 5,
                    ),
                    /* Text(
                        "${(double.parse(widget.duration) / 60).toStringAsFixed(2)} mnt"), */
                    Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Text("Dari"),
                        title: Text(widget.newLocation[0].address),
                        trailing: Icon(Icons.pin_drop_outlined),
                      ),
                    ),
                    LimitedBox(
                      maxWidth: double.infinity,
                      maxHeight: 100,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.newLocation.length - 1,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                leading: Text("Ke - ${index + 1}"),
                                title:
                                    Text(widget.newLocation[index + 1].address),
                                trailing: Icon(Icons.pin_drop_outlined),
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _collapsedBody() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                ),
                child: Image.network(widget.driverBid.fotoDriver.toString()),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 2),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: Text(
                      widget.driverBid.namaDriver.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: Text(
                      widget.driverBid.kendaraan.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16),
                    ),
                  ),
                ],
              )),
              const Icon(
                Icons.airport_shuttle_outlined,
                color: Colors.greenAccent,
                size: 40,
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    boxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    double bottomNavigationBarHeight =
        (MediaQuery.of(context).viewInsets.bottom > 0) ? 0 : 50;
    double appBarHeight = MediaQuery.of(context).size.height * 0.1;
    if (appBarHeight < 95) appBarHeight = 95;
    double minHeightBox =
        MediaQuery.of(context).size.height * 0.3 - bottomNavigationBarHeight;
    double maxHeightBox = MediaQuery.of(context).size.height -
        appBarHeight -
        bottomNavigationBarHeight;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SlidingBox(
          controller: boxController,
          minHeight: 140,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          color: Colors.white,
          style: BoxStyle.shadow,
          backdrop: Backdrop(
            overlay: true,
            color: Colors.white,
            body: _backdrop(),
            appBar: BackdropAppBar(actions: []),
          ),
          body: _body(),
          collapsed: true,
          collapsedBody: _collapsedBody(),
        ),
        bottomNavigationBar: Container(
            padding: EdgeInsets.only(top: 5, bottom: 15),
            height: 70,
            color: Colors.white,
            child: ListTile(
              title: Container(
                padding: EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primaryColor),
                width: double.infinity,
                child: Center(
                  child: Marquee(
                      text: statusDriver,
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: 20.0,
                      velocity: 100.0,
                      pauseAfterRound: Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: Duration(milliseconds: 1000),
                      decelerationCurve: Curves.easeOut,
                      style: TextStyle(fontSize: 18)),
                ),
              ),
              trailing: Material(
                color: primaryColor,
                shape: StadiumBorder(),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            )));
  }
}
