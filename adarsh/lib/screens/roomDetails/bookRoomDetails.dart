import 'dart:async';
import 'dart:convert';
import 'package:adarsh/modals/roomBookModel.dart';
import 'package:adarsh/screens/ConfirmBookingandMakePayment/confirmBookingandMakePayment.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookRoomDetailPage extends StatefulWidget {
  final String roomId;
  final int price;
  final String roomType;
  final int roomNumber;
  final String description;
  final String checkInDate;
  final String checkOutDate;

  const BookRoomDetailPage(
      {Key key,
      this.roomId,
      this.roomType,
      this.roomNumber,
      /* this.name, this.location*/ this.description,
      this.price,
      this.checkInDate,
      this.checkOutDate})
      : super(key: key);

  @override
  _BookRoomDetailPageState createState() => _BookRoomDetailPageState();
}

class _BookRoomDetailPageState extends State<BookRoomDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Positioned(
          //     left: 16,
          //     top: 32,
          //     child: IconButton(
          //       icon: Icon(Icons.arrow_back_ios),
          //       onPressed: () {
          //         Navigator.of(context).pop();
          //       },
          //     )),
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
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                SizedBox(height: 5),
                                Text.rich(
                                  TextSpan(children: [
                                    WidgetSpan(
                                        child: Icon(
                                      Icons.location_on,
                                      size: 16.0,
                                      color: Colors.grey,
                                    )),
                                    TextSpan(text: "Kindon Plaza , Aurangabad")
                                  ]),
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12.0),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        children: <Widget>[
                          Text(
                            "Total Charges : " + this.widget.price.toString(),
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    "" +
                                        DateTime.parse(this.widget.checkInDate)
                                            .day
                                            .toString() +
                                        "-" +
                                        DateTime.parse(this.widget.checkInDate)
                                            .month
                                            .toString() +
                                        "-" +
                                        DateTime.parse(this.widget.checkInDate)
                                            .year
                                            .toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ]),
                        SizedBox(
                          width: 110.0,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    "" +
                                        "" +
                                        DateTime.parse(this.widget.checkOutDate)
                                            .day
                                            .toString() +
                                        "-" +
                                        DateTime.parse(this.widget.checkOutDate)
                                            .month
                                            .toString() +
                                        "-" +
                                        DateTime.parse(this.widget.checkOutDate)
                                            .year
                                            .toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
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
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(Icons.wifi,
                                                    color: Colors.blue[600]),
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
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(Icons.wifi,
                                                    color: Colors.blue[600]),
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
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(Icons.bathtub,
                                                    color: Colors.blue[600]),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
