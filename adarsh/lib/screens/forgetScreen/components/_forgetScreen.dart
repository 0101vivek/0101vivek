import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:adarsh/modals/userLogin.dart';
import 'package:adarsh/modals/userOtp.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/SignUp/signupscreen.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:adarsh/screens/forgetScreen/components/otpcheckscreeen.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../serverUrl.dart';

class ForgetScreen extends StatefulWidget {
  @override
  _ForgetScreenState createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  bool isSubmit = false;
  final formKey = GlobalKey<FormState>();
  bool isPassword = true;
  OTPModel model = new OTPModel();

  Future sendOTP() async {
    setState(() {
      isSubmit = true;
    });
    String data = generateOtp();
    print(data);
    try {
      http.Response response = await http.post(
        serverUrl + '/send_otp',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode({
          "mobile": model.phoneNo,
          "name": null,
          "status": "Forget Password",
          "otp": data.toString()
        }),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("OTP", data);
      setState(() {
        isSubmit = false;
      });
      if (response.statusCode == 200) {
        navigateotpscreen();
      } else if (response.statusCode == 404) {
        showInvalidDataMessage();
      } else if (response.statusCode == 500) {
        showSomethingWentWrong();
      }
    } catch (e) {}
  }

  generateOtp() {
    Random random = new Random();
    int r;
    String otp = "";
    for (int i = 0; i < 4; i++) {
      r = 0 + random.nextInt(9 - 0);
      otp = otp + r.toString();
    }
    return otp;
  }

  navigateotpscreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPPage()),
      );
    });
  }

  showInvalidDataMessage() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: "User Not Registered",
        confirmBtnColor: Colors.blue[800]);
  }

  showSomethingWentWrong() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      confirmBtnColor: Colors.blue[800],
      title: "Oops...",
      text: "Sorry, something went wrong",
    );
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
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
              (Route<dynamic> route) => false);
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.blue[900],
              Colors.blue[800],
              Colors.blue[400]
            ])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      FadeAnimation(
                          1.5,
                          Text(
                            "Forget Password",
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60))),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 60,
                          ),
                          FadeAnimation(
                              1.4,
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(225, 95, 27, .3),
                                          blurRadius: 10,
                                          offset: Offset(0, 5))
                                    ]),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      // Container(
                                      //   padding: EdgeInsets.all(15),
                                      //   decoration: BoxDecoration(
                                      //       border: Border(
                                      //           bottom: BorderSide(
                                      //               color: Colors.grey[200]))),
                                      //   child: TextFormField(
                                      //     keyboardType:
                                      //         TextInputType.emailAddress,
                                      //     onChanged: (String value) {
                                      //       model.email = value;
                                      //     },
                                      //     validator: (String value) {
                                      //       if (value.isEmpty ||
                                      //           !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      //               .hasMatch(value)) {
                                      //         return 'Enter a valid Email!';
                                      //       }
                                      //       return null;
                                      //     },
                                      //     decoration: InputDecoration(
                                      //         hintText: "Email",
                                      //         prefixIcon:
                                      //             Icon(Icons.email_outlined),
                                      //         hintStyle:
                                      //             TextStyle(color: Colors.grey),
                                      //         border: InputBorder.none),
                                      //   ),
                                      // ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          keyboardType: TextInputType.phone,
                                          onChanged: (String value) {
                                            model.phoneNo = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                value.length < 10 ||
                                                !RegExp(r"^[0-9]")
                                                    .hasMatch(value)) {
                                              return 'Enter a valid Mobile No';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: 'Mobile Number',
                                              prefixIcon: Icon(Icons.phone),
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          isSubmit != false
                              ? new Container(
                                  child: new Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: new Center(
                                          child: new CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context).primaryColor),
                                      ))),
                                )
                              : FadeAnimation(
                                  1.6,
                                  Container(
                                    height: 50,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 50),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.blue[800]),
                                    child: FlatButton(
                                      onPressed: () async {
                                        try {
                                          if (formKey.currentState.validate()) {
                                            await sendOTP();
                                          } else {
                                            return;
                                          }
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          "Send Otp".toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  )),
                          SizedBox(
                            height: 20,
                          ),
                          FadeAnimation(
                              1.5,
                              InkWell(
                                onTap: () {
                                  var time = Timer(Duration(seconds: 2), () {});
                                  time.cancel();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => SignUpScreen()),
                                      (Route<dynamic> route) => false);
                                },
                                child: Text(
                                  "Don't Have an Account ? Sign Up",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateY").add(
          Duration(milliseconds: 500), Tween(begin: -30.0, end: 0.0),
          curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(0, animation["translateY"]), child: child),
      ),
    );
  }
}
