import 'dart:async';
import 'dart:convert';
import 'package:adarsh/modals/roomBookModel.dart';
import 'package:adarsh/screens/ConfirmBookingandMakePayment/confirmBookingandMakePayment.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class BookRoomDetailPage extends StatefulWidget {
  final String roomId;
  final int price;
  final String roomType;
  final int roomNumber;
  final String checkInDate;
  final String checkOutDate;
  final String status;
  final String orderId;
  final String paymentStatus;
  final String paytmOrderId;
  const BookRoomDetailPage(
      {Key key,
      this.roomId,
      this.orderId,
      this.roomType,
      this.roomNumber,
      this.status,
      this.price,
      this.checkInDate,
      this.checkOutDate,
      this.paytmOrderId,
      this.paymentStatus})
      : super(key: key);

  @override
  _BookRoomDetailPageState createState() => _BookRoomDetailPageState();
}

class _BookRoomDetailPageState extends State<BookRoomDetailPage> {
  @override
  List month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.of(context).pop();
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
            return Container(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Check Internet Connection !",
                      style: TextStyle(fontSize: 15))
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
                padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 440),
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Table(
                              children: [
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Order ID : '.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child:
                                          Text(this.widget.orderId.toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Room Number'.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          this.widget.roomNumber.toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Room Type'.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          this.widget.roomType.toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Total Charges ".toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child:
                                          Text(this.widget.price.toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Room Status".toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          this.widget.status == 'RoomCancelled'
                                              ? "Cancelled"
                                              : 'Booked')),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Check In Date".toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text((DateTime.parse(this
                                                          .widget
                                                          .checkInDate)
                                                      .day +
                                                  1)
                                              .toString() +
                                          " " +
                                          month[DateTime.parse(this
                                                          .widget
                                                          .checkInDate)
                                                      .month -
                                                  1]
                                              .toString() +
                                          " " +
                                          DateTime.parse(
                                                  this.widget.checkInDate)
                                              .year
                                              .toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Check Out Date".toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text((DateTime.parse(this
                                                          .widget
                                                          .checkOutDate)
                                                      .day +
                                                  1)
                                              .toString() +
                                          " " +
                                          month[DateTime.parse(this
                                                          .widget
                                                          .checkOutDate)
                                                      .month -
                                                  1]
                                              .toString() +
                                          " " +
                                          DateTime.parse(
                                                  this.widget.checkOutDate)
                                              .year
                                              .toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Payment Order ID'.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          this.widget.paytmOrderId.toString())),
                                ]),
                                TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Payment Order ID'.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(this
                                          .widget
                                          .paymentStatus
                                          .toString())),
                                ]),
                              ],
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
