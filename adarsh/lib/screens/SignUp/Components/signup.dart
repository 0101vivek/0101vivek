import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:adarsh/modals/userSignup.dart';
import 'package:adarsh/screens/Login/login_screen.dart';
import 'package:adarsh/screens/SignUp/Components/otpPage.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:adarsh/serverUrl.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;

Color blueColors = Colors.blue[900];
Color blueLightColors = Colors.blue[400];

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  Model model = new Model();
  String radioButtonVal = 'N';
  String internetConnection = 'available';
  bool isSubmit = false;
  bool isPassword = true;
  bool serverError = false;
  String otpNo;
  bool userAlreadyRegisterd = false;

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Future signup() async {
    setState(() {
      isSubmit = true;
    });

    http.Response response = await http.post(serverUrl + '/signup',
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({
          "first_name": model.firstName,
          "last_name": model.lastName,
          "mobileno": model.phoneNumber,
          "email": model.email,
          "password": model.password,
          "otpVerified": false
        }));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    if (response.statusCode == 409) {
      await prefs.setString("token", '');
      setState(() {
        isSubmit = false;
        serverError = false;
        userAlreadyRegisterd = true;
      });
    } else if (response.statusCode == 500) {
      await prefs.setString("token", '');
      setState(() {
        isSubmit = false;
        serverError = true;
      });
    } else if (response.statusCode == 200) {
      setState(() {
        isSubmit = false;
        serverError = false;
        userAlreadyRegisterd = false;
      });
    }
  }

  voidCheckEmploye({String isEmployee}) {
    if (isEmployee == 'Y') {
      return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]))),
        child: TextFormField(
          keyboardType: TextInputType.text,
          onChanged: (String value) {
            // model.email = value;
          },
          validator: (String value) {
            if (value
                    .isEmpty /*||
                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)*/
                ) {
              return 'Enter a valid Employee Id';
            }
            return null;
          },
          decoration: InputDecoration(
              hintText: "Employee Id",
              prefixIcon: Icon(Icons.account_circle_sharp),
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none),
        ),
      );
    } else {
      return Container();
    }
  }

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
          "mobile": model.phoneNumber,
          "name": model.firstName + " " + model.lastName.toString(),
          "status": "Sign Up",
          "otp": data.toString()
        }),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("OTP", data);
      setState(() {
        isSubmit = false;
      });
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
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          )),
                      SizedBox(
                        height: 10,
                      ),
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
                                          keyboardType: TextInputType.text,
                                          onChanged: (String value) {
                                            model.firstName = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                !RegExp(r"^[a-zA-Z]")
                                                    .hasMatch(value)) {
                                              return 'Enter a valid First Name!';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: "First Name",
                                              prefixIcon: Icon(
                                                  Icons.account_circle_sharp),
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          onChanged: (String value) {
                                            model.lastName = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                !RegExp(r"^[a-zA-Z]")
                                                    .hasMatch(value)) {
                                              return 'Enter a valid Last Name!';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: "Last Name",
                                              prefixIcon: Icon(
                                                  Icons.account_circle_sharp),
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          keyboardType: TextInputType.phone,
                                          onChanged: (String value) {
                                            model.phoneNumber = value;
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
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          onChanged: (String value) {
                                            model.email = value;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                    .hasMatch(value)) {
                                              return 'Enter a valid Email!';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: "Email",
                                              prefixIcon:
                                                  Icon(Icons.email_outlined),
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
                                                    value.length <
                                                        6 /* ||
                                                !RegExp(r'^(?=.*?[a-z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                                                    .hasMatch(value)*/
                                                ) {
                                              return 'Password minimum length must be 6 ';
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
                                      // Container(
                                      //   padding: EdgeInsets.all(10),
                                      //   decoration: BoxDecoration(
                                      //       border: Border(
                                      //           bottom: BorderSide(
                                      //               color: Colors.grey[200]))),
                                      //   child: Column(
                                      //     children: <Widget>[
                                      //       Text(
                                      //         'Are You Employee of the MetalMan?',
                                      //         style: new TextStyle(
                                      //             fontSize: 15.0,
                                      //             fontWeight: FontWeight.bold,
                                      //             color: Colors.blue[900]),
                                      //       ),
                                      //       ButtonBar(
                                      //         alignment: MainAxisAlignment.center,
                                      //         children: [
                                      //           Radio(
                                      //             value: 'Y',
                                      //             groupValue: radioButtonVal,
                                      //             onChanged: (value) {
                                      //               setState(() {
                                      //                 radioButtonVal = 'Y';
                                      //               });
                                      //             },
                                      //             activeColor: blueColors,
                                      //           ),
                                      //           Text("Yes"),
                                      //           Radio(
                                      //             value: 'N',
                                      //             groupValue: radioButtonVal,
                                      //             onChanged: (value) {
                                      //               setState(() {
                                      //                 radioButtonVal = 'N';
                                      //               });
                                      //             },
                                      //             activeColor: blueColors,
                                      //           ),
                                      //           Text("No")
                                      //         ],
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // voidCheckEmploye(
                                      //     isEmployee: radioButtonVal),
                                    ],
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 30,
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
                                        if (!(formKey.currentState
                                            .validate())) {
                                          return;
                                        } else {
                                          await signup();
                                          // await sendOtp();

                                          if (userAlreadyRegisterd == false) {
                                            Future.delayed(
                                                Duration(milliseconds: 1000),
                                                () async {
                                              await sendOTP().then((value) => {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    OTPPage(
                                                                      password:
                                                                          model
                                                                              .password,
                                                                      firstName:
                                                                          model
                                                                              .firstName,
                                                                      lastName:
                                                                          model
                                                                              .lastName,
                                                                      email: model
                                                                          .email,
                                                                      phoneNumber:
                                                                          model
                                                                              .phoneNumber,
                                                                    )))
                                                  });
                                            });
                                          } else if (userAlreadyRegisterd ==
                                              true) {
                                            CoolAlert.show(
                                                context: context,
                                                type: CoolAlertType.error,
                                                confirmBtnColor:
                                                    Colors.blue[800],
                                                title:
                                                    "User already registered",
                                                onConfirmBtnTap: () {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Login_Screen()),
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                });
                                          } else if (serverError == true) {
                                            CoolAlert.show(
                                              context: context,
                                              type: CoolAlertType.error,
                                              title: 'Oops...',
                                              text:
                                                  'Sorry, something went wrong',
                                              loopAnimation: false,
                                            );
                                          }
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          "Sign Up",
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
                                  Future.delayed(Duration(milliseconds: 1000),
                                      () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Login_Screen()),
                                        (Route<dynamic> route) => false);
                                  });
                                },
                                child: Text(
                                  "Already have an account ? Sign In",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey),
                                ),
                              )),
                        ],
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderContainer extends StatelessWidget {
  var text = "Signin";

  HeaderContainer(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [blueColors, blueLightColors],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60))),
      child: Stack(
        children: <Widget>[
          Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 30),
              )),
        ],
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
