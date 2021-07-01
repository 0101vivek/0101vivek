import 'dart:async';
import 'dart:convert';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:adarsh/screens/BookingHistory/historyDetails.dart';
import 'package:adarsh/screens/roomDetails/bookRoomDetails.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  DateTime initialDate = (new DateTime.now()).subtract(new Duration(days: 15));
  DateTime lastDate = (new DateTime.now().add(new Duration(days: 15)));
  DateTime setInitialDate =
      (new DateTime.now()).subtract(new Duration(days: 15));
  DateTime setLastDate = (new DateTime.now().add(new Duration(days: 15)));

  @override
  void initState() {
    super.initState();
  }

  Future fetchDetailsByDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    http.Response response =
        await http.post('http://www.metalmanauto.xyz:2078/getDetailsByDate',
            headers: {'Content-Type': 'application/json;charset=UTF-8'},
            body: jsonEncode({
              "token": prefs.getString('token'),
              "initialDate": setInitialDate.toString(),
              "lastDate": setLastDate.toString()
            }));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      var list = parsed['result'] as List;
      List<Details> data = list.map((i) => Details.fromJson(i)).toList();
      print(data.length);
      return data;
    }
  }

  bool roomCancel = true;

  Future<bool> futureCancelRoom(String roomId) async {
    setState(() {
      roomCancel = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response response = await http.post(
        'http://www.metalmanauto.xyz:2078/cancel_room',
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
          actions: [
            // PopupMenuButton<String>(
            //   onSelected: handleClick,
            //   itemBuilder: (BuildContext context) {
            //     return {'Oldest Booked', 'Newest Booked', 'Price'}
            //         .map((String choice) {
            //       return PopupMenuItem<String>(
            //         value: choice,
            //         child: Text(choice),
            //       );
            //     }).toList();
            //   },
            // ),
            IconButton(
                onPressed: () async {
                  final List<DateTime> picked =
                      await DateRangePicker.showDatePicker(
                          context: context,
                          initialFirstDate: initialDate,
                          initialLastDate: lastDate,
                          firstDate: new DateTime(2015),
                          lastDate: new DateTime(DateTime.now().year + 3));
                  if (picked != null && picked.length == 2) {
                    setState(() {
                      setInitialDate = picked[0];
                      setLastDate = picked[1];
                    });
                  }
                },
                icon: Icon(Icons.calendar_today_rounded))
          ],
          title: Text(
            "Past Room History",
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
                    future: fetchDetailsByDate(),
                    builder: (context, snapshot) {
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
                                    Color faintcolour = (snapshot.data[index]
                                                    .bookingStatus ==
                                                "RoomCancelled" &&
                                            snapshot.data[index].payment ==
                                                "Cancel")
                                        ? Color(0xffFF5B95)
                                        : (snapshot.data[index].bookingStatus ==
                                                        "RoomPreBooked" &&
                                                    snapshot.data[index]
                                                            .payment ==
                                                        "Pending") ||
                                                (snapshot.data[index]
                                                            .bookingStatus ==
                                                        "RoomBooked" &&
                                                    snapshot.data[index]
                                                            .payment ==
                                                        "Pending")
                                            ? Color(0xFFFF8A65)
                                            : Color(0xff42E695);

                                    Color darkcolour = (snapshot.data[index]
                                                    .bookingStatus ==
                                                "RoomCancelled" &&
                                            snapshot.data[index].payment ==
                                                "Cancel")
                                        ? Color(0xffF8556D)
                                        : (snapshot.data[index].bookingStatus ==
                                                        "RoomPreBooked" &&
                                                    snapshot.data[index]
                                                            .payment ==
                                                        "Pending") ||
                                                (snapshot.data[index]
                                                            .bookingStatus ==
                                                        "RoomBooked" &&
                                                    snapshot.data[index]
                                                            .payment ==
                                                        "Pending")
                                            ? Color(0xFFFF8A65)
                                            : Color(0xff3BB2B8);

                                    return InkWell(
                                      onTap: () {
                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookRoomDetailPage(
                                                        orderId: snapshot
                                                            .data[index]
                                                            .orderId,
                                                        roomType: snapshot
                                                            .data[index]
                                                            .roomType,
                                                        price: snapshot
                                                            .data[index]
                                                            .totalAmount,
                                                        roomNumber: snapshot
                                                            .data[index]
                                                            .roomNumber,
                                                        status: snapshot
                                                            .data[index]
                                                            .bookingStatus,
                                                        checkInDate: snapshot
                                                            .data[index]
                                                            .roomBookingDay,
                                                        checkOutDate: snapshot
                                                            .data[index]
                                                            .roomEndingDay,
                                                      )));
                                        });
                                      },
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
                                                  faintcolour,
                                                  darkcolour
                                                ],
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomRight),
                                            boxShadow: [
                                              BoxShadow(
                                                color: darkcolour,
                                                blurRadius: 12,
                                                offset: Offset(0, 6),
                                              ),
                                            ]),
                                        child: Column(
                                          children: <Widget>[
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
                                                    Row(
                                                      children: [
                                                        Column(
                                                          children: [],
                                                        )
                                                      ],
                                                    ),
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
                                                        fontSize: 14,
                                                        color: Colors.black54,
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "Charges :  ",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black54,
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    340
                                                                ? 40
                                                                : 80),
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
                                                          child: snapshot
                                                                      .data[
                                                                          index]
                                                                      .bookingStatus ==
                                                                  "RoomPreBooked"
                                                              ? Center(
                                                                  child:
                                                                      Container(
                                                                    height: 40,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      color: Colors
                                                                              .blue[
                                                                          800],
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.black26,
                                                                          blurRadius:
                                                                              15.0,
                                                                          offset: Offset(
                                                                              2.0,
                                                                              4.4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Cancel',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13.0,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.w600,
                                                                            letterSpacing: .1),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  height: 2),
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
                              ? Container(
                                  child: Center(
                                      child: Text(
                                          "Currently You Don't have order history")),
                                )
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
