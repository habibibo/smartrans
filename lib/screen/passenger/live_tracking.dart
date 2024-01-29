import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong2/latlong.dart';
import 'package:signgoogle/model/customer_transaction.dart';
import 'package:signgoogle/model/location.dart';
import 'package:signgoogle/model/notif/driver_bid.dart';
import 'package:signgoogle/model/pricing_detail.dart';
import 'package:signgoogle/model/transaction.dart';
import 'package:signgoogle/utils/mapbox.dart';

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
    //
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
          appBar: BackdropAppBar(
              /* searchBox: SearchBox(
                controller: textEditingController,
                color: Colors.white,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18),
                body: Center(
                  child: Text(
                    "Search Result",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 20),
                  ),
                ),
                draggableBody: true,
              ), */
              actions: [
                /* Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]),
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(20),
                    child: IconButton(
                      iconSize: 25,
                      icon: Icon(Icons.search_rounded,
                          size: 27,
                          color: Theme.of(context).colorScheme.onPrimary),
                      onPressed: () {
                        textEditingController.text = "";
                        boxController.showSearchBox();
                      },
                    ),
                  ),
                ), */
              ]),
        ),
        body: _body(),
        collapsed: true,
        collapsedBody: _collapsedBody(),
      ),
    );
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
                  builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.redAccent,
                        size: 48.0,
                      ),
                  height: 60),
            ]),
          ],
        ),
        /* Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 40, right: 10),
            child: FloatingActionButton(
              onPressed: () {
                boxController.isBoxOpen
                    ? boxController.closeBox()
                    : boxController.openBox();
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ) */
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
                children: [Text("Rp. ${widget.pricingDetails.price}")],
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
                  Text(jsonDecode(
                      widget.transaction.paymentmethod.toString())["name"]),
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
          )
          /* Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: const EdgeInsets.all(0),
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(40),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  color: Theme.of(context).colorScheme.onBackground,
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  color: Theme.of(context).colorScheme.onBackground,
                  icon: const Icon(Icons.add_location_alt_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  color: Theme.of(context).colorScheme.onBackground,
                  icon: const Icon(Icons.bookmark_border_rounded),
                )
              ],
            ),
          ), */
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
        /* Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          padding: const EdgeInsets.all(0),
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onBackground.withAlpha(40),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                color: Theme.of(context).colorScheme.onBackground,
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                onPressed: () {},
                color: Theme.of(context).colorScheme.onBackground,
                icon: const Icon(Icons.add_location_alt_outlined),
              ),
              IconButton(
                onPressed: () {},
                color: Theme.of(context).colorScheme.onBackground,
                icon: const Icon(Icons.bookmark_border_rounded),
              )
            ],
          ),
        ) */
      ],
    );
  }
}

class MaterialListItem extends StatelessWidget {
  final Icon? icon;
  final Widget child;
  final VoidCallback onPressed;

  const MaterialListItem(
      {super.key, this.icon, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double iconSizeHeight = 50;
    return SizedBox(
      height: iconSizeHeight,
      child: MaterialButton(
        padding: const EdgeInsets.all(0),
        minWidth: MediaQuery.of(context).size.height,
        splashColor: Colors.white,
        highlightColor: Colors.white,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: onPressed,
        child: Row(
          children: [
            if (icon != null)
              SizedBox(
                width: iconSizeHeight + 10,
                height: iconSizeHeight,
                child: icon,
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/* class LiveTracking extends StatelessWidget {
  Transaction transaction;
  PricingDetails pricingDetails;
  String routeTransaction;
  String customerTransaction;

  LiveTracking(
      {Key? key,
      required this.transaction,
      required this.pricingDetails,
      required this.routeTransaction,
      required this.customerTransaction})
      : super(key: key);


  @override
  void initState(){
    super.initState();
    print(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
} */
