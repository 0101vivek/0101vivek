import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:adarsh/components/round_buttons.dart';
import 'package:adarsh/constant.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/Login/login_screen.dart';
import 'package:adarsh/screens/SignUp/signupscreen.dart';
import 'package:adarsh/screens/Welcome/components/backGround.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String internetConnection = 'available';

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome To Adarsh'.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue[600]),
              ),
              SizedBox(height: size.height * 0.03),
              Image.asset(
                'assets/images/Zep3.png',
                height: size.height * 0.20,
              ),
              SizedBox(height: size.height * 0.10),
              RoundButton(
                text: 'LOGIN',
                onpresed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  if (prefs.getString('token') != null &&
                      prefs.getString('token') != '') {
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    });
                  } else {
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login_Screen()),
                      );
                    });
                  }
                },
              ),
              RoundButton(
                color: KPrimaryColor,
                text: 'SIGN UP',
                onpresed: () {
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
