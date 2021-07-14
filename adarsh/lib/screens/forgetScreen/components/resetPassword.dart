import 'dart:async';
import 'dart:convert';
import 'package:adarsh/modals/userLogin.dart';
import 'package:adarsh/modals/userOtp.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/Login/components/login.dart';
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

class ResetPassword extends StatefulWidget {
  final String phoneNo;

  const ResetPassword({Key key, this.phoneNo}) : super(key: key);
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  bool isSubmit = false;
  final formKey = GlobalKey<FormState>();
  bool isPassword = true;
  bool isPassword1 = true;
  String password;
  String password1;

  Future updatePassword() async {
    setState(() {
      isSubmit = true;
    });
    var url = serverUrl + "/reset_password";
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonEncode({'phoneNo': this.widget.phoneNo, 'password': password1}),
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      showSuccess();
    } else {
      showSomethingWentWrong();
    }

    setState(() {
      isSubmit = false;
    });
  }

  showSuccess() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        // title: "Oops...",
        text: "Password Updated Successfully",
        onCancelBtnTap: () {
          navigateloginscreen();
        },
        onConfirmBtnTap: () {
          navigateloginscreen();
        });
  }

  navigateloginscreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    });
  }

  showSomethingWentWrong() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
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
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false);
          });
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
                            "Reset Password",
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
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          obscureText: isPassword,
                                          keyboardType: TextInputType.text,
                                          onChanged: (String value) {
                                            password = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                    value.length <
                                                        6 /*||
                        !RegExp(r'^(?=.*?[a-z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                            .hasMatch(value)*/
                                                ) {
                                              return 'Enter valid password';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: "Enter Password",
                                              prefixIcon: Icon(
                                                Icons.lock,
                                              ),
                                              suffix: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isPassword = !isPassword;
                                                  });
                                                },
                                                child: Icon(
                                                  isPassword
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                              ),
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          obscureText: isPassword1,
                                          keyboardType: TextInputType.text,
                                          onChanged: (String value) {
                                            password1 = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                    password != password1 ||
                                                    value.length <
                                                        6 /*||
                        !RegExp(r'^(?=.*?[a-z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                            .hasMatch(value)*/
                                                ) {
                                              return 'Enter valid password';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: "Enter Password again",
                                              prefixIcon: Icon(
                                                Icons.lock,
                                              ),
                                              suffix: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isPassword1 = !isPassword1;
                                                  });
                                                },
                                                child: Icon(
                                                  isPassword1
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                              ),
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
                                            await updatePassword();
                                          } else {
                                            return;
                                          }
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          "Reset".toUpperCase(),
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
