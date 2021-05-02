import 'dart:async';
import 'dart:convert';

import 'package:adarsh/components/round_buttons.dart';
import 'package:adarsh/constant.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/Login/login_screen.dart';
import 'package:adarsh/screens/SignUp/signupscreen.dart';
import 'package:adarsh/screens/Welcome/components/backGround.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Body extends StatelessWidget {
  Future getName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');
      var url = "http://192.168.0.100:3000/getName";
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      var parse = json.decode(response.body);
      // print(response.body);
      return parse['name'];
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                print(prefs.getString('token'));
                if (prefs.getString('token') != '') {
                  String name = await getName();
                  var time = Timer(Duration(seconds: 2), () {});
                  time.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              name: name,
                            )),
                  );
                } else {
                  var time = Timer(Duration(seconds: 2), () {});
                  time.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login_Screen()),
                  );
                }
              },
            ),
            RoundButton(
              color: KPrimaryColor,
              text: 'SIGN UP',
              onpresed: () {
                var time = Timer(Duration(seconds: 2), () {});
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
