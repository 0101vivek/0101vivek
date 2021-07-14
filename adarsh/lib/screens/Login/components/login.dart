import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adarsh/modals/userLogin.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/SignUp/signupscreen.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:adarsh/screens/forgetScreen/components/_forgetScreen.dart';
import 'package:adarsh/serverUrl.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  LoginModel model = new LoginModel();
  bool isSubmit = false;
  final formKey = GlobalKey<FormState>();
  String internetConnection = 'available';
  bool isPassword = true;
  String name;
  String msg;

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);
    setState(() {
      isSubmit = true;
    });
    var url = serverUrl + "/login";
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonEncode({
        'mobileno': model.phoneNo,
        'password': model.password,
      }),
    );

    var parse = jsonDecode(response.body);

    if (response.statusCode == 404) {
      await prefs.setString('token', "");
      setState(() {
        msg = parse['msg'];
      });
    } else if (response.statusCode == 409) {
      await prefs.setString('token', "");
      setState(() {
        msg = parse['msg'];
      });
    } else if (response.statusCode == 200) {
      await prefs.setString('token', parse['token']);
      await prefs.setBool('isLogin', true);
      await prefs.setString('name', parse['name']);
      setState(() {
        msg = parse['msg'];
      });
    } else if (response.statusCode == 500) {
      await prefs.setString('token', "");
      setState(() {
        msg = parse['msg'];
      });
    }
    setState(() {
      isSubmit = false;
    });
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
                      FadeAnimation(
                          1,
                          Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      FadeAnimation(
                          1.3,
                          Text(
                            "Welcome Back",
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
                                              hintText: "Mobile Number",
                                              prefixIcon: Icon(
                                                  Icons.phone_android_rounded),
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
                                          obscureText: isPassword,
                                          keyboardType: TextInputType.text,
                                          onChanged: (String value) {
                                            model.password = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                value.length < 6) {
                                              return 'Enter valid password';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: "Password",
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
                                            await login();
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            String token =
                                                prefs.getString("token");
                                            print(token);
                                            if (token != "") {
                                              Future.delayed(
                                                  Duration(milliseconds: 1500),
                                                  () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomePage()),
                                                );
                                              });
                                            } else {
                                              CoolAlert.show(
                                                  context: context,
                                                  confirmBtnColor:
                                                      Colors.blue[800],
                                                  type: CoolAlertType.error,
                                                  title: msg,
                                                  onConfirmBtnTap: () {
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LoginScreen()),
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                  });
                                            }
                                          } else {
                                            return;
                                          }
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          "Login",
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
                                  Future.delayed(Duration(milliseconds: 1500),
                                      () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ForgetScreen()),
                                    );
                                  });
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          FadeAnimation(
                              1.5,
                              InkWell(
                                onTap: () {
                                  Future.delayed(Duration(milliseconds: 1500),
                                      () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => SignUpScreen()),
                                    );
                                  });
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
