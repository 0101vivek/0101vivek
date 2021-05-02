import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:adarsh/screens/BookingHistory/HistoryPage.dart';
import 'package:adarsh/screens/availableRoomforCancellation/availableRoomForCancellation.dart';
import 'package:adarsh/screens/roomDetails/roomDetails.dart';
import 'package:http/http.dart' as http;
import 'package:adarsh/screens/HomeBooking/components/rooms.dart';
import 'package:adarsh/screens/profile/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant.dart';

class HomePage extends StatefulWidget {
  final String name;
  const HomePage({Key key, this.name}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  Future _future;
  Future _future1;
  Future _future2;
  Timer time1, time2, time3;
  int currentIndex = 0;
  List<RoomDetails> _searchResult = [];
  bool active = true;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (active) {
      setUpTimedFetchDelux();
      setUpTimedFetchLuxury();
      setUpTimedFetchSuperDelux();
    }
  }

  @override
  void dispose() {
    super.dispose();
    time1.cancel();
    time2.cancel();
    time3.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<Null> search() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      active = true;
    } else if (state == AppLifecycleState.inactive) {
      active = false;
    } else if (state == AppLifecycleState.detached) {
      active = false;
    } else if (state == AppLifecycleState.paused) {
      active = false;
    }
  }

  setUpTimedFetchLuxury() {
    time1 = Timer.periodic(Duration(milliseconds: 400), (timer) {
      if (active) {
        setState(() {
          _future = fetchLuxuryRooms();
        });
      }
    });
  }

  setUpTimedFetchDelux() {
    time2 = Timer.periodic(Duration(milliseconds: 400), (timer) {
      if (active) {
        setState(() {
          _future1 = fetchDeluxRooms();
        });
      }
    });
  }

  setUpTimedFetchSuperDelux() {
    time3 = Timer.periodic(Duration(milliseconds: 400), (timer) {
      if (active) {
        setState(() {
          _future2 = fetchSuperDeluxRooms();
        });
      }
    });
  }

  TextEditingController _textEditingController = new TextEditingController();
  Widget image_carousel = new Container(
    padding: EdgeInsets.symmetric(
      horizontal: 10,
    ),
    height: 200.0,
    child: new Carousel(
      boxFit: BoxFit.cover,
      images: [
        AssetImage('assets/house/house01.png'),
        AssetImage('assets/house/house01.png'),
        AssetImage('assets/house/house01.png'),
        AssetImage('assets/house/house01.png'),
      ],
      autoplay: true,
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: Duration(milliseconds: 2500),
      dotSize: 3.0,
      dotColor: KPrimaryColor,
      indicatorBgPadding: 2.0,
    ),
  );

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      elevation: 9,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int newValue) {
        if (active) {
          setState(() {
            currentIndex = newValue;
          });
        }
      },
      selectedItemColor: KPrimaryColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
        BottomNavigationBarItem(
            icon: Icon(Icons.business_center_sharp), title: Text('Booking')),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), title: Text('History')),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), title: Text('Profile'))
      ],
    );
  }

  Future fetchLuxuryRooms() async {
    try {
      final response = await http.get('http://192.168.0.100:3000/luxury_room');
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        var list = parsed['result'] as List;
        List<RoomDetails> data =
            list.map((i) => RoomDetails.fromJson(i)).toList();
        return data;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future fetchDeluxRooms() async {
    try {
      final response = await http.get('http://192.168.0.100:3000/delux_room');
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        var list = parsed['result'] as List;
        List<RoomDetails> data =
            list.map((i) => RoomDetails.fromJson(i)).toList();
        return data;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future fetchSuperDeluxRooms() async {
    try {
      final response =
          await http.get('http://192.168.0.100:3000/super_delux_room');
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        var list = parsed['result'] as List;
        List<RoomDetails> data =
            list.map((i) => RoomDetails.fromJson(i)).toList();
        return data;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: (currentIndex == 3)
              ? ProfilePage()
              : (currentIndex == 2)
                  ? History()
                  : (currentIndex == 1)
                      ? AvailableRoomForCancellation()
                      : SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              SafeArea(
                                  child: Container(),
                                  top: true,
                                  left: true,
                                  right: true),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                height: MediaQuery.of(context).size.height / 6,
                                child: Column(children: <Widget>[
                                  Expanded(
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Hello ${widget.name}",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "Find your hotel",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        )
                                      ])),
                                  //     Expanded(
                                  //         child: Container(
                                  //             margin: EdgeInsets.symmetric(
                                  //                 horizontal: 0, vertical: 22),
                                  //             decoration: BoxDecoration(
                                  //                 color: Colors.grey[200],
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(16)),
                                  //             padding: EdgeInsets.symmetric(
                                  //                 horizontal: 16),
                                  //             child: TextField(
                                  //               controller: _textEditingController,
                                  //               onChanged: (value) {},
                                  //               decoration: InputDecoration(
                                  //                   border: InputBorder.none,
                                  //                   hintText: "Search for rooms...",
                                  //                   hintStyle: TextStyle(
                                  //                       color: Colors.grey[500],
                                  //                       fontWeight:
                                  //                           FontWeight.bold),
                                  //                   icon: Icon(
                                  //                     Icons.search,
                                  //                     color: Colors.grey[500],
                                  //                   )),
                                  //             )))
                                ]),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height +
                                    MediaQuery.of(context).size.height / 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    image_carousel,
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 40, 10, 0),
                                      child: Text(
                                        "Luxury Room's",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    FutureBuilder(
                                        future: _future,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            // print(snapshot.error);
                                          }
                                          return snapshot.hasData
                                              ? Expanded(
                                                  flex: 8,
                                                  child: ListView.builder(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          snapshot.data == null
                                                              ? 0
                                                              : snapshot
                                                                  .data.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        // String _base64 =
                                                        //     snapshot.data[index]
                                                        //         .image;
                                                        // var image = utf8
                                                        //     .encode(_base64);
                                                        // var encoded1 = base64
                                                        //     .encode(image);
                                                        // var bytes = base64
                                                        //     .decode(encoded1);

                                                        // print(snapshot
                                                        //     .data[index].image);

                                                        return InkWell(
                                                          onTap: () async {
                                                            var time = Timer(
                                                                Duration(
                                                                    seconds: 3),
                                                                () {});
                                                            time.cancel();

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => RoomDetailPage(
                                                                      description: snapshot
                                                                          .data[
                                                                              index]
                                                                          .description,
                                                                      roomNumber: snapshot
                                                                          .data[
                                                                              index]
                                                                          .roomNumber,
                                                                      roomId: snapshot
                                                                          .data[
                                                                              index]
                                                                          .id,
                                                                      roomType:
                                                                          "Luxury",
                                                                      price: snapshot
                                                                          .data[
                                                                              index]
                                                                          .charges)),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 24,
                                                                    top: 8,
                                                                    bottom: 8),
                                                            width: 180,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .14),
                                                                      blurRadius:
                                                                          3,
                                                                      spreadRadius:
                                                                          3),
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                color: Colors
                                                                    .white),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage(
                                                                                'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                                                                            fit: BoxFit
                                                                                .cover),
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(16),
                                                                            topRight: Radius.circular(16))),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          "Room No : " +
                                                                              snapshot.data[index].roomNumber.toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Kindon Plaza , Aurangabad",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rs." +
                                                                              snapshot.data[index].charges.toString() +
                                                                              "/day",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                12,
                                                                          ),
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
                                              : Center(
                                                  child: snapshot.data == null
                                                      ? Container(
                                                          height: 250,
                                                          child: Center(
                                                            child: Text(
                                                                "No Room Available"),
                                                          ))
                                                      : CircularProgressIndicator(),
                                                );
                                        }),
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 40, 10, 0),
                                      child: Text(
                                        "Delux Room's",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    FutureBuilder(
                                        future: _future1,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            // print(snapshot.error);
                                          }
                                          return snapshot.hasData
                                              ? Expanded(
                                                  flex: 8,
                                                  child: ListView.builder(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          snapshot.data == null
                                                              ? 0
                                                              : snapshot
                                                                  .data.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        // DecoImage = snapshot
                                                        //     .data[index].image;
                                                        // _bytesImage = Base64Decoder()
                                                        //     .convert(DecoImage);
                                                        // Widget image =
                                                        //     Image.memory(_bytesImage);
                                                        return InkWell(
                                                          onTap: () async {
                                                            var time = Timer(
                                                                Duration(
                                                                    seconds: 3),
                                                                () {});
                                                            time.cancel();

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => RoomDetailPage(
                                                                      description: snapshot
                                                                          .data[
                                                                              index]
                                                                          .description,
                                                                      roomNumber: snapshot
                                                                          .data[
                                                                              index]
                                                                          .roomNumber,
                                                                      roomId: snapshot
                                                                          .data[
                                                                              index]
                                                                          .id,
                                                                      roomType:
                                                                          "Delux",
                                                                      price: snapshot
                                                                          .data[
                                                                              index]
                                                                          .charges)),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 24,
                                                                    top: 8,
                                                                    bottom: 8),
                                                            width: 180,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .14),
                                                                      blurRadius:
                                                                          3,
                                                                      spreadRadius:
                                                                          3),
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                color: Colors
                                                                    .white),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage(
                                                                                'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                                                                            fit: BoxFit
                                                                                .cover),
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(16),
                                                                            topRight: Radius.circular(16))),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          "Room No : " +
                                                                              snapshot.data[index].roomNumber.toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Kindon Plaza , Aurangabad",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rs." +
                                                                              snapshot.data[index].charges.toString() +
                                                                              "/day",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                12,
                                                                          ),
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
                                              : Center(
                                                  child: snapshot.data == null
                                                      ? Container(
                                                          height: 250,
                                                          child: Center(
                                                            child: Text(
                                                                "No Room Available"),
                                                          ))
                                                      : CircularProgressIndicator(),
                                                );
                                        }),
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 40, 10, 0),
                                      child: Text(
                                        "Super Delux Room's",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    FutureBuilder(
                                        future: _future2,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            // print(snapshot.error);
                                          }
                                          return snapshot.hasData
                                              ? Expanded(
                                                  flex: 8,
                                                  child: ListView.builder(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          snapshot.data == null
                                                              ? 0
                                                              : snapshot
                                                                  .data.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () async {
                                                            var time = Timer(
                                                                Duration(
                                                                    seconds: 3),
                                                                () {});
                                                            time.cancel();

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => RoomDetailPage(
                                                                      description: snapshot
                                                                          .data[
                                                                              index]
                                                                          .description,
                                                                      roomNumber: snapshot
                                                                          .data[
                                                                              index]
                                                                          .roomNumber,
                                                                      roomId: snapshot
                                                                          .data[
                                                                              index]
                                                                          .id,
                                                                      roomType:
                                                                          "SuperDelux",
                                                                      price: snapshot
                                                                          .data[
                                                                              index]
                                                                          .charges)),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 24,
                                                                    top: 8,
                                                                    bottom: 8),
                                                            width: 180,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .14),
                                                                      blurRadius:
                                                                          3,
                                                                      spreadRadius:
                                                                          3),
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                color: Colors
                                                                    .white),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                            image: NetworkImage(
                                                                                'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                                                                            fit: BoxFit
                                                                                .cover),
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(16),
                                                                            topRight: Radius.circular(16))),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          "Room No : " +
                                                                              snapshot.data[index].roomNumber.toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Kindon Plaza , Aurangabad",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "Rs." +
                                                                              snapshot.data[index].charges.toString() +
                                                                              "/day",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                12,
                                                                          ),
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
                                              : Center(
                                                  child: snapshot.data == null
                                                      ? Container(
                                                          height: 250,
                                                          child: Center(
                                                            child: Text(
                                                                "No Room Available"),
                                                          ))
                                                      : CircularProgressIndicator(),
                                                );
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
          bottomNavigationBar: _buildBottomNavBar()),
    );
  }
}
