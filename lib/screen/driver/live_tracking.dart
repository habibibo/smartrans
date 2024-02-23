import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:latlong2/latlong.dart';
import 'package:signgoogle/model/location.dart';
import 'package:signgoogle/utils/mapbox.dart';

class LiveTrackingDriver extends StatefulWidget {
  List<Location> locationPassenger;
  double currentLat;
  double currentLng;
  String orderDetail;
  LiveTrackingDriver(
      {Key? key,
      required this.locationPassenger,
      required this.currentLat,
      required this.currentLng,
      required this.orderDetail})
      : super(key: key);

  @override
  State<LiveTrackingDriver> createState() => _LiveTrackingDriverState();
}

class _LiveTrackingDriverState extends State<LiveTrackingDriver> {
  final BoxController boxController = BoxController();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
  }

  _backdrop() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(widget.currentLat, widget.currentLng),
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
                  point: LatLng(double.parse(widget.locationPassenger[0].lat),
                      double.parse(widget.locationPassenger[0].lng)),
                  builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.redAccent,
                        size: 48.0,
                      ),
                  height: 60),
            ]),
          ],
        ),
      ],
    );
  }

  _body() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  //child: Image.network(widget.driverBid.fotoDriver.toString()),
                  child: Icon(Icons.verified_user_outlined),
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
                        //widget.driverBid.namaDriver.toString(),
                        "Nama Penumpang",
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
                        //widget.driverBid.kendaraan.toString(),
                        "Lokasi",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                    ),
                  ],
                )),
                const Icon(
                  Icons.pin_drop_outlined,
                  color: Colors.greenAccent,
                  size: 40,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          /* Card(
            elevation: 5,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rp. ${widget.pricingDetails.price}"),
                  SizedBox(
                    height: 5,
                  ),
                  Text(jsonDecode(
                      widget.transaction.paymentmethod.toString())["name"]),
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
                  Text("${widget.distance} km"),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      "${(double.parse(widget.duration) / 60).toStringAsFixed(2)} mnt"),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Text("From"),
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
                              leading: Text("To - ${index + 1}"),
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
          ) */
        ],
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
                //child: Image.network(widget.driverBid.fotoDriver.toString()),
                child: Icon(Icons.supervised_user_circle),
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
                      //widget.driverBid.namaDriver.toString(),
                      "Nama Penumpang",
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
                      //widget.driverBid.kendaraan.toString(),
                      "Lokasi",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16),
                    ),
                  ),
                ],
              )),
              const Icon(
                Icons.pin_drop_outlined,
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
      body: SlidingBox(
        controller: boxController,
        minHeight: 200,
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
    );
  }
}
