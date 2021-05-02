import 'dart:async';
import 'dart:convert';

import 'package:adarsh/screens/BookingHistory/historyDetails.dart';
import 'package:adarsh/screens/roomDetails/bookRoomDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  void initState() {
    super.initState();
  }

  Future fetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response response =
        await http.post('http://192.168.0.100:3000/booking_history',
            headers: {'Content-Type': 'application/json;charset=UTF-8'},
            body: jsonEncode({
              "token": prefs.getString('token'),
            }));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      print(parsed);
      var list = parsed['result'] as List;
      List<Details> data = list.map((i) => Details.fromJson(i)).toList();
      print(data);
      return data;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: false,
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
                                  return InkWell(
                                    onTap: () {
                                      print("Hello");
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(top: 8, bottom: 8),
                                      width: MediaQuery.of(context).size.width,
                                      height: 330,
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.14),
                                                blurRadius: 3,
                                                spreadRadius: 3),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: Colors.white),
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                                                      fit: BoxFit.fill),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  16),
                                                          topRight:
                                                              Radius.circular(
                                                                  16))),
                                            ),
                                          ),
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
                                                    "Room No :      " +
                                                        snapshot.data[index]
                                                            .roomNumber
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Room Type :   " +
                                                        snapshot.data[index]
                                                            .roomType,
                                                    style: TextStyle(
                                                      color: Colors.grey,
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
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        "      Rs." +
                                                            snapshot.data[index]
                                                                .totalAmount
                                                                .toString(),
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(width: 80),
                                                      InkWell(
                                                        onTap: () async {
                                                          var time = Timer(
                                                              Duration(
                                                                  seconds: 3),
                                                              () {});
                                                          time.cancel();
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          BookRoomDetailPage(
                                                                            roomType:
                                                                                snapshot.data[index].roomType,
                                                                            price:
                                                                                snapshot.data[index].totalAmount,
                                                                            roomNumber:
                                                                                snapshot.data[index].roomNumber,
                                                                            description:
                                                                                snapshot.data[index].description,
                                                                            checkInDate:
                                                                                snapshot.data[index].roomBookingDay,
                                                                            checkOutDate:
                                                                                snapshot.data[index].roomEndingDay,
                                                                          )));
                                                        },
                                                        child: Center(
                                                          child: Container(
                                                            height: 30,
                                                            width: 100,
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
    );
  }
}
