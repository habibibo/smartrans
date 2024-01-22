import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

class BottomSheetCollapse extends StatefulWidget {
  const BottomSheetCollapse({super.key});

  @override
  State<BottomSheetCollapse> createState() => _BottomSheetCollapseState();
}

class _BottomSheetCollapseState extends State<BottomSheetCollapse> {
  String scheduleDate =
      "${DateTime.now().year} - ${DateTime.monthsPerYear} - ${DateTime.now().day}";
  // "${DateTime.now().day} - ${DateTime.monthsPerYear} - ${DateTime.now().year}";
  String scheduleTime = "${DateTime.now().hour}.${DateTime.now().minute}";
  String paymentMethod = "Pilih pembayaranmu ya...";
  String promo = "-";
  bool dragg = true;
  int selectedIndex = -1;
  String defaultPrice = "Rp 25.000";
  String offerPrice = "";
  TextEditingController offerPriceController = TextEditingController();
  bool showVisibleOffer = false;
  bool hideDefaultPrice = true;
  List<bool> negoToggled =
      List.filled(20, false); // Track if "Nego" is toggled for each item
  List<String> suggestions = [];
  //List<flutterMapDirection.LatLng> newLatLng = [];
  List<DateTime> dates = [];
  final CurrencyTextFieldController offeringController =
      CurrencyTextFieldController(
    currencySymbol: "Rp",
    thousandSymbol: ".",
    decimalSymbol: "",
    enableNegative: false,
    numberOfDecimals: 0,
  );

  void showOffer(BuildContext context, thisIndex) {
    setState(() {
      offeringController.text = "";
    });
    showFlexibleBottomSheet<void>(
        minHeight: 0,
        initHeight: 0.6,
        maxHeight: 1,
        context: context,
        isSafeArea: false,
        bottomSheetColor: Colors.transparent,
        builder: (context, controller, offset) {
          return Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: offeringController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 25),
                    decoration: InputDecoration(),
                    onChanged: (value) {
                      offeringController.text = value;
                    },
                    autofocus: true,
                  ),
                ),
                Container(
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        offerPrice = offeringController.text;
                        showVisibleOffer = true;
                        negoToggled[thisIndex] = !negoToggled[thisIndex];
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Coba nego",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    minWidth: double.infinity,
                    height: 50,
                    color: primaryColor,
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Saran pengemudi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        )),
                  ],
                ),
              ),
              Container(
                height: 240,
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedIndex != index) {
                              // Reset strike-through when another item is selected
                              selectedIndex = index;
                              negoToggled = List.filled(20, false);
                              showVisibleOffer = false;
                            } else {
                              selectedIndex =
                                  -1; // Deselect if the same item is selected again
                            }
                          });
                        },
                        child: Card(
                          color: selectedIndex == index
                              ? Colors
                                  .orange[100] // Change color for selected item
                              : Colors.white,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Smart Trans XL $index",
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
                                          Container(
                                            child: selectedIndex == index
                                                ? Column(
                                                    children: [
                                                      Text(
                                                        defaultPrice,
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            decoration: negoToggled[
                                                                    index]
                                                                ? TextDecoration
                                                                    .lineThrough // Apply strike-through if "Nego" is toggled
                                                                : null),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            showVisibleOffer,
                                                        child: Text(
                                                          offerPrice,
                                                          style: TextStyle(
                                                            color: primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    defaultPrice,
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                          ),
                                          Container(
                                            child: selectedIndex == index
                                                ? InkWell(
                                                    onTap: () {
                                                      showOffer(context, index);
                                                    },
                                                    child: Card(
                                                      elevation: 2,
                                                      color: Colors.orange,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          "Nego",
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ) // Change color for selected item
                                                : Container(),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.alarm),
                                          SizedBox(width: 5),
                                          Text(
                                            "1-10 menit",
                                            style:
                                                TextStyle(color: Colors.grey),
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
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 12, right: 12),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.orange[200]),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tanggal ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Jam ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Pembayaran ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Promo ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          ": ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ": ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ": ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ": ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheduleDate,
                          //Jiffy(scheduleDate).format('dd-MM-YYYY').toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          scheduleTime,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          paymentMethod,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          promo,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )),
      ],
    );
  }
}
