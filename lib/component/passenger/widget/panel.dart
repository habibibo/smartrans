import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class PassengerPanel extends StatefulWidget {
  const PassengerPanel({super.key});

  @override
  State<PassengerPanel> createState() => _PassengerPanelState();
}

class _PassengerPanelState extends State<PassengerPanel> {
  String scheduleDate =
      "${DateTime.now().year} - ${DateTime.monthsPerYear} - ${DateTime.now().day}";
  // "${DateTime.now().day} - ${DateTime.monthsPerYear} - ${DateTime.now().year}";
  String scheduleTime = "${DateTime.now().hour}.${DateTime.now().minute}";
  String paymentMethod = "Pilih pembayaranmu ya...";
  String promo = "-";
  bool dragg = true;
  final PanelController panelController = PanelController();
  PanelState panelState = PanelState.CLOSED;
  DateTime changeDateTomorrow = DateTime.now().add(Duration(days: 1));
  DateTime changeDateSchedule = DateTime.now().add(Duration(days: 1));
  String changeTimeNow = "${DateTime.now().hour} : ${DateTime.now().minute}";
  TextEditingController _searchController = TextEditingController();
  //final BoxController boxController = BoxController();
  //PassengerRepo passengerRepo = PassengerRepo();
  num lat = 0;
  num lng = 0;

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
                height: 100,
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
      ],
    );
  }
}
