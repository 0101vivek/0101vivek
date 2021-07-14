import 'dart:async';
import 'dart:convert';
import 'package:adarsh/modals/roomBookModel.dart';
import 'package:adarsh/screens/ConfirmBookingandMakePayment/ConfirmBookingMakePayment.dart';
// import 'package:adarsh/screens/ConfirmBookingandMakePayment/confirmBookingandMakePayment.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomDetailPage extends StatefulWidget {
  final String roomId;
  final int price;
  final String roomType;
  final int roomNumber;
  final String roomStartDate;
  final String description;
  final String preBooked;

  const RoomDetailPage(
      {Key key,
      this.roomId,
      this.preBooked,
      this.roomStartDate,
      this.roomType,
      this.roomNumber,
      /* this.name, this.location*/ this.description,
      this.price})
      : super(key: key);

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  DateTime selectedCheckInDate = DateTime.now();
  DateTime selectedCheckOutDate = DateTime.now().add(Duration(days: 1));
  bool isSubmit = true;
  String userId = '';
  int numberOfDays = 0;
  String total_amount = '';
  RoomBookModel model = new RoomBookModel();
  bool checkInDate = true;
  bool checkOutDate = true;
  TextEditingController guestNo;
  int totalGuest = 1;
  // final formKey = GlobalKey<FormState>();
  getNumberOfDays() {
    Duration dur = selectedCheckOutDate.difference(selectedCheckInDate);
    setState(() {
      numberOfDays = dur.inDays;
      print(numberOfDays);
    });
  }

  get_total_amount() async {
    if (mounted) {
      setState(() {
        total_amount = (numberOfDays * widget.price).toString();
        print(total_amount);
        model.totalAmount = total_amount;
      });
    }
  }

  showAlertDialogForCheckIn(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        setState(() {
          selectedCheckInDate = DateTime.now();
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Invalid Check In Date"),
      content: Text("Enter Proper Date"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogForCheckOut(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        setState(() {
          selectedCheckOutDate = DateTime.now().add(Duration(days: 1));
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Invalid Check Out Date"),
      content: Text("Enter Proper Date"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _selectCheckInDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedCheckInDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedCheckInDate)
      setState(() {
        selectedCheckInDate = picked;
      });
  }

  Future _selectCheckOutDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedCheckInDate.add(Duration(days: 1)),
        firstDate: selectedCheckInDate.add(Duration(days: 1)),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedCheckOutDate)
      setState(() {
        selectedCheckOutDate = picked;
      });
  }

  _launchMaps() async {
    String googleUrl = 'https://maps.app.goo.gl/Xuh9ffiPo1eS9AFD7';
    // String appleUrl =
    //     'https://maps.apple.com/?sll=${trip.origLocationObj.lat},${trip.origLocationObj.lon}';
    if (await canLaunch(googleUrl)) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else {
      throw 'Could not launch url';
    }
  }

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        });
      },
      child: OfflineBuilder(
        debounceDuration: Duration.zero,
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          if (connectivity == ConnectivityResult.none) {
            return Scaffold(
                body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Check Internet Connection !",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          backgroundColor: Colors.white))
                ],
              ),
            ));
          }
          return child;
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                  foregroundDecoration: BoxDecoration(color: Colors.black26),
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)))),

              // InkWell(
              //     onTap: () {
              //       Navigator.push(context,
              //           MaterialPageRoute(builder: (context) => Login_Screen()));
              //     },
              //     child: Padding(
              //         padding: EdgeInsets.all(35.0),
              //         child: const Icon(Icons.arrow_back_ios))),
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 400),
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          widget.preBooked == 'pre-booked'
                              ? Text(
                                  "*Note this room is unavailable after " +
                                      this.widget.roomStartDate.toString() +
                                      " 11 AM",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 5),
                                    Text(
                                      "Room No : " +
                                          this
                                              .widget
                                              .roomNumber
                                              .toString()
                                              .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 12),
                                    InkWell(
                                      onTap: () {
                                        _launchMaps();
                                      },
                                      child: Text.rich(
                                        TextSpan(children: [
                                          WidgetSpan(
                                              child: Icon(
                                            Icons.location_on,
                                            size: 16.0,
                                            color: Colors.grey,
                                          )),
                                          TextSpan(
                                              text: "Kindon Plaza , Aurangabad")
                                        ]),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12.0),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "Rs. " +
                                        this
                                            .widget
                                            .price
                                            .toString()
                                            .toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  Text(
                                    "/per day",
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 30.0),
                          Text(
                            "Description".toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14.0),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            this.widget.description.toString(),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 14.0),
                          ),
                          // const SizedBox(height: 30.0),
                          // Text(
                          //   "Number Of Guest".toUpperCase(),
                          //   style: TextStyle(
                          //       fontWeight: FontWeight.w600, fontSize: 14.0),
                          // ),
                          // const SizedBox(height: 10.0),
                          // Form(
                          //   key: formKey,
                          //   child: Container(
                          //     padding: EdgeInsets.all(1),
                          //     decoration: BoxDecoration(
                          //         border: Border(
                          //             bottom:
                          //                 BorderSide(color: Colors.grey[200]))),
                          //     child: TextFormField(
                          //       keyboardType: TextInputType.number,
                          //       onChanged: (String value) {
                          //         totalGuest = int.parse(value);
                          //       },
                          //       validator: (String value) {
                          //         if (value.isEmpty ||
                          //             int.parse(value) > 3 ||
                          //             int.parse(value) < 1) {
                          //           return 'Enter a Guest Number between 1 to 3';
                          //         }
                          //         return null;
                          //       },
                          //       decoration: InputDecoration(
                          //           hintText: "Total Number of Guest",
                          //           prefixIcon:
                          //               Icon(Icons.account_circle_sharp),
                          //           hintStyle: TextStyle(color: Colors.grey),
                          //           border: InputBorder.none),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 20.0),
                          Row(children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Check In Date",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                        "${selectedCheckInDate.toLocal()}"
                                            .split(' ')[0],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      RaisedButton(
                                        onPressed: () async {
                                          await _selectCheckInDate(context);
                                          print(selectedCheckInDate);
                                          if (widget.preBooked ==
                                              'pre-booked') {
                                            DateFormat inputFormat =
                                                DateFormat("dd-MM-yyyy");
                                            DateTime dateTime = inputFormat
                                                .parse(widget.roomStartDate);
                                            if (dateTime.isBefore(
                                                selectedCheckInDate)) {
                                              showAlertDialogForCheckIn(
                                                  context);
                                              checkInDate = false;
                                            } else {
                                              checkInDate = true;
                                            }
                                          } else if (selectedCheckInDate
                                              .isBefore(DateTime.now().subtract(
                                                  Duration(hours: 23)))) {
                                            showAlertDialogForCheckIn(context);
                                            checkInDate = false;
                                          } else {
                                            checkInDate = true;
                                          }
                                        },
                                        child: Text('Select date'),
                                      ),
                                    ],
                                  ),
                                ]),
                            SizedBox(
                              width: MediaQuery.of(context).size.width < 340
                                  ? MediaQuery.of(context).size.width / 6
                                  : MediaQuery.of(context).size.width / 4,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Check Out Date",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                        "${selectedCheckOutDate.toLocal()}"
                                            .split(' ')[0],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      RaisedButton(
                                        onPressed: () async {
                                          await _selectCheckOutDate(context);
                                          print(selectedCheckOutDate);
                                          if (widget.preBooked ==
                                              'pre-booked') {
                                            DateFormat inputFormat =
                                                DateFormat("dd-MM-yyyy");
                                            DateTime dateTime = inputFormat
                                                .parse(widget.roomStartDate);
                                            if (selectedCheckOutDate
                                                .isAfter(dateTime)) {
                                              showAlertDialogForCheckOut(
                                                  context);
                                              checkOutDate = false;
                                            } else {
                                              checkOutDate = true;
                                            }
                                          } else if (!selectedCheckOutDate
                                              .isAfter(selectedCheckInDate)) {
                                            showAlertDialogForCheckOut(context);
                                            checkOutDate = false;
                                          } else {
                                            checkOutDate = true;
                                          }
                                        },
                                        child: Text('Select date'),
                                      ),
                                    ],
                                  ),
                                ]),
                          ]),
                          const SizedBox(height: 20.0),
                          this.widget.roomType == 'Luxury'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Amminities",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.0),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                height: 32,
                                                width: 32,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 3,
                                                      spreadRadius: 2,
                                                    )
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(Icons.local_parking,
                                                    color: Colors.blue[600]),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text("Parking")
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                height: 32,
                                                width: 32,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 3,
                                                      spreadRadius: 2,
                                                    )
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(Icons.ac_unit,
                                                    color: Colors.blue[600]),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text("Ac")
                                            ],
                                          ),
                                        ]),
                                  ],
                                )
                              : this.widget.roomType == 'Delux'
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Amminities",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        )
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(
                                                        Icons.local_parking,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Parking")
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        )
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(Icons.ac_unit,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Ac")
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(Icons.wifi,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Wifi")
                                                ],
                                              ),
                                            ]),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Amminities",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        )
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(
                                                        Icons.local_parking,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Parking")
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        )
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(Icons.ac_unit,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Ac")
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(Icons.wifi,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Wifi")
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 2,
                                                        )
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Icon(Icons.bathtub,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("Bath")
                                                ],
                                              )
                                            ]),
                                      ],
                                    ),
                          const SizedBox(height: 30.0),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              color: Colors.blue[900],
                              textColor: Colors.white,
                              child: Text(
                                "Book Now",
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                              onPressed: () async {
                                // if (formKey.currentState.validate()) {
                                await getNumberOfDays();
                                await get_total_amount();
                                if (checkInDate && checkOutDate) {
                                  Future.delayed(Duration(milliseconds: 1000),
                                      () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ConfirmOrderPage(
                                                  roomId: widget.roomId,
                                                  // description:
                                                  //     widget.description,
                                                  startingDay:
                                                      selectedCheckInDate
                                                          .toString(),
                                                  endingDay:
                                                      selectedCheckOutDate
                                                          .toString(),
                                                  totalAmount: int.parse(
                                                      model.totalAmount),
                                                  roomType: widget.roomType,
                                                  // totalGuest: totalGuest,
                                                  roomNumber: widget.roomNumber,
                                                )));
                                  });
                                } else {
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.error,
                                    title: "",
                                    text: "Enter valid data",
                                  );
                                }
                                // }
                                // else {
                                //   return;
                                // }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
