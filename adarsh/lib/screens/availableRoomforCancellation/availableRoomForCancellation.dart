import 'dart:async';
import 'dart:convert';

import 'package:adarsh/screens/BookingHistory/historyDetails.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/roomDetails/bookRoomDetails.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AvailableRoomForCancellation extends StatefulWidget {
  @override
  _AvailableRoomForCancellationState createState() =>
      _AvailableRoomForCancellationState();
}

class _AvailableRoomForCancellationState
    extends State<AvailableRoomForCancellation> {
  @override
  void initState() {
    super.initState();
  }

  bool roomCancel = true;

  Future fetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response response = await http.post(
        'http://www.metalmanauto.xyz:2078/booking_room_cancellation_history',
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({
          "token": prefs.getString('token'),
        }));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      var list = parsed['result'] as List;
      List<Details> data = list.map((i) => Details.fromJson(i)).toList();
      // print(data);
      return data;
    }
  }

  Future<bool> futureCancelRoom(String roomId) async {
    setState(() {
      roomCancel = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response response = await http.post(
        'https://vanillacode.tech/cancel_room',
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body:
            jsonEncode({"token": prefs.getString('token'), "roomId": roomId}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        roomCancel = false;
      });
      return true;
    } else {
      setState(() {
        roomCancel = false;
      });
      print("Error occured");
      return false;
    }
  }

  Widget build(BuildContext context) {
    return OfflineBuilder(
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
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue[900],
          automaticallyImplyLeading: false,
          title: Text(
            "Recently Book Room",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                FutureBuilder(
                    future: fetchDetails(),
                    builder: (context, snapshot) {
                      print(snapshot.data);
                      if (snapshot.hasError) {
                        print(snapshot.error);
                      }
                      return snapshot.hasData
                          ? Expanded(
                              flex: 8,
                              child: ListView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data == null
                                      ? 0
                                      : snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 140,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Color(0xff42E695),
                                                  Color(0xff3BB2B8)
                                                ],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomRight),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xff3BB2B8),
                                                blurRadius: 12,
                                                offset: Offset(0, 6),
                                              ),
                                            ]),
                                        child: Column(
                                          children: <Widget>[
                                            // Expanded(
                                            //   flex: 5,
                                            //   child: Container(
                                            //     decoration: BoxDecoration(
                                            //         image: DecorationImage(
                                            //             image: NetworkImage(
                                            //                 'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                                            //             fit: BoxFit.fill),
                                            //         borderRadius:
                                            //             BorderRadius.only(
                                            //                 topLeft: Radius
                                            //                     .circular(16),
                                            //                 topRight:
                                            //                     Radius.circular(
                                            //                         16))),
                                            //   ),
                                            // ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Order ID :      " +
                                                          snapshot.data[index]
                                                              .orderId
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Room No :      " +
                                                          snapshot.data[index]
                                                              .roomNumber
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Room Type :   " +
                                                          snapshot.data[index]
                                                              .roomType,
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "Charges :  ",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          "      Rs." +
                                                              snapshot
                                                                  .data[index]
                                                                  .totalAmount
                                                                  .toString(),
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 30),
                                                        InkWell(
                                                          onTap: () async {
                                                            Future.delayed(
                                                                Duration(
                                                                    milliseconds:
                                                                        500),
                                                                () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          BookRoomDetailPage(
                                                                            orderId:
                                                                                snapshot.data[index].orderId,
                                                                            roomType:
                                                                                snapshot.data[index].roomType,
                                                                            price:
                                                                                snapshot.data[index].totalAmount,
                                                                            roomNumber:
                                                                                snapshot.data[index].roomNumber,
                                                                            status:
                                                                                snapshot.data[index].bookingStatus,
                                                                            checkInDate:
                                                                                snapshot.data[index].roomBookingDay,
                                                                            checkOutDate:
                                                                                snapshot.data[index].roomEndingDay,
                                                                          )));
                                                            });
                                                          },
                                                          child: Center(
                                                            child: Container(
                                                              height: 30,
                                                              width: 70,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Colors
                                                                    .blue[800],
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black26,
                                                                    blurRadius:
                                                                        15.0,
                                                                    offset:
                                                                        Offset(
                                                                            2.0,
                                                                            4.4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  'View',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13.0,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      letterSpacing:
                                                                          .1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        InkWell(
                                                          onTap: () async {
                                                            CoolAlert.show(
                                                                context:
                                                                    context,
                                                                type:
                                                                    CoolAlertType
                                                                        .confirm,
                                                                text:
                                                                    'Do you want to Cancel Room',
                                                                confirmBtnText:
                                                                    'Yes',
                                                                cancelBtnText:
                                                                    'No',
                                                                confirmBtnColor:
                                                                    Colors
                                                                        .green,
                                                                onConfirmBtnTap:
                                                                    () async {
                                                                  bool room = await futureCancelRoom(
                                                                      snapshot
                                                                          .data[
                                                                              index]
                                                                          .roomId);
                                                                  if (room) {
                                                                    CoolAlert.show(
                                                                        context: context,
                                                                        type: CoolAlertType.success,
                                                                        text: 'Room Cancel Successfully',
                                                                        onConfirmBtnTap: () {
                                                                          Future.delayed(
                                                                              Duration(milliseconds: 500),
                                                                              () {
                                                                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()),
                                                                                (Route<dynamic> route) => false);
                                                                          });
                                                                        });
                                                                  } else {
                                                                    CoolAlert
                                                                        .show(
                                                                      context:
                                                                          context,
                                                                      type: CoolAlertType
                                                                          .error,
                                                                      title:
                                                                          'Oops...',
                                                                      text:
                                                                          'Sorry, something went wrong',
                                                                    );
                                                                  }
                                                                });
                                                          },
                                                          child: Center(
                                                            child: Container(
                                                              height: 30,
                                                              width: 70,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Colors
                                                                    .blue[800],
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black26,
                                                                    blurRadius:
                                                                        15.0,
                                                                    offset:
                                                                        Offset(
                                                                            2.0,
                                                                            4.4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13.0,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      letterSpacing:
                                                                          .1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }))
                          : snapshot.data == null
                              ? Container()
                              : Center(
                                  child: CircularProgressIndicator(),
                                );
                    }),
                SizedBox(height: 135),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
