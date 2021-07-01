import 'dart:async';
import 'dart:convert';
import 'package:adarsh/screens/Login/components/login.dart';
import 'package:adarsh/screens/updateEmailandPhoneNo/updateData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // userDetails = getUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future userDetails;

  Future getUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      print(token);
      final response = await http.post(
        'http://www.metalmanauto.xyz:2078/user_history',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        return parsed;
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
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
          backgroundColor: Colors.grey.shade100,
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FutureBuilder(
                    future: getUserDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // print(snapshot.error);
                      }
                      return snapshot.hasData
                          ? Container(
                              child: Column(children: <Widget>[
                                ProfileHeader(
                                  avatar: NetworkImage(
                                      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                                  title: snapshot.data['result']['first_name']
                                          .toString()
                                          .toUpperCase() +
                                      " " +
                                      snapshot.data['result']['last_name']
                                          .toString()
                                          .toUpperCase(),
                                  actions: <Widget>[
                                    MaterialButton(
                                      color: Colors.white,
                                      shape: CircleBorder(),
                                      elevation: 0,
                                      child: Icon(Icons.edit),
                                      onPressed: () {
                                        var time =
                                            Timer(Duration(seconds: 2), () {});
                                        time.cancel();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateDataScreen(
                                                      name: snapshot
                                                              .data['result']
                                                                  ['first_name']
                                                              .toString()
                                                              .toUpperCase() +
                                                          " " +
                                                          snapshot
                                                              .data['result']
                                                                  ['last_name']
                                                              .toString()
                                                              .toUpperCase(),
                                                      email: snapshot
                                                              .data['result']
                                                          ['email'],
                                                      phone: snapshot
                                                              .data['result']
                                                          ['mobileno'],
                                                    )));
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                                UserInfo(
                                  email: snapshot.data['result']['email']
                                      .toString(),
                                  mobileNo: snapshot.data['result']['mobileno']
                                      .toString(),
                                ),
                                const SizedBox(height: 15.0),
                                Container(
                                  height: 50,
                                  margin: EdgeInsets.symmetric(horizontal: 50),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.blue[800]),
                                  child: FlatButton(
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove('token');
                                      prefs.remove('name');
                                      prefs.remove('isLogin');
                                      Future.delayed(
                                          Duration(milliseconds: 500), () {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginScreen()),
                                                (Route<dynamic> route) =>
                                                    false);
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        "Log Out",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )
                          : new Container(
                              child: new Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: new Center(
                                      child: new CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).primaryColor),
                                  ))),
                            );
                    }),
              ],
            ),
          )),
    );
  }
}

class UserInfo extends StatelessWidget {
  final String email;
  final String mobileNo;

  const UserInfo({Key key, this.email, this.mobileNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            alignment: Alignment.topLeft,
            child: Text(
              "User Information",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Card(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ...ListTile.divideTiles(
                        color: Colors.grey,
                        tiles: [
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text("Email"),
                            subtitle: Text(email),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text("Phone"),
                            subtitle: Text(mobileNo),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final ImageProvider<dynamic> avatar;
  final String title;

  final List<Widget> actions;

  const ProfileHeader(
      {Key key, @required this.avatar, @required this.title, this.actions})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Ink(
          height: 300,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[900],
            Colors.blue[800],
            Colors.blue[400]
          ])),
        ),
        if (actions != null)
          Container(
            width: double.infinity,
            height: 300,
            padding: const EdgeInsets.only(bottom: 0.0, right: 0.0),
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 250),
          child: Column(
            children: <Widget>[
              Avatar(
                image: avatar,
                radius: 45,
                backgroundColor: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 4.0,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.title,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  final ImageProvider<dynamic> image;
  final Color borderColor;
  final Color backgroundColor;
  final double radius;
  final double borderWidth;

  const Avatar(
      {Key key,
      @required this.image,
      this.borderColor = Colors.grey,
      this.backgroundColor,
      this.radius = 30,
      this.borderWidth = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius + borderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor != null
            ? backgroundColor
            : Theme.of(context).primaryColor,
        child: CircleAvatar(
          radius: radius - borderWidth,
          backgroundImage: image,
        ),
      ),
    );
  }
}
