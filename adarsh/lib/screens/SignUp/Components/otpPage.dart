import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:adarsh/screens/Login/login_screen.dart';
import 'package:adarsh/screens/SignUp/Components/signup.dart';
import 'package:adarsh/screens/forgetScreen/components/resetPassword.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../serverUrl.dart';

final inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8.0),
  borderSide: BorderSide(color: Colors.grey.shade400),
);

final inputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
  border: inputBorder,
  focusedBorder: inputBorder,
  enabledBorder: inputBorder,
);

String otp;
String num1;
String num2;
String num3;
String num4;

class OTPPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String password;
  const OTPPage(
      {Key key,
      this.firstName,
      this.lastName,
      this.phoneNumber,
      this.email,
      this.password})
      : super(key: key);
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  int minute = 0;
  int seconds = 59;
  Timer time1;
  bool isSubmit = false;
  bool isPassword = true;
  bool serverError = false;
  // String otpNo;

  void initState() {
    super.initState();
    setUpTimedForOtp();
  }

  Future resendOtp() async {
    String data = generateOtp();
    print(data);
    try {
      http.Response response = await http.post(
        serverUrl + '/send_otp',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode({
          "mobile": this.widget.phoneNumber,
          "name": this.widget.firstName + " " + this.widget.lastName.toString(),
          "status": "Sign Up",
          "otp": data.toString()
        }),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("OTP", data);
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

  bool dataSubmitted = false;

  setUpTimedForOtp() {
    time1 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (minute == 0 && seconds == 0) {
        time1.cancel();
      } else {
        setState(() {
          seconds = seconds - 1;
        });
      }
    });
  }

  void dispose() {
    super.dispose();
    time1.cancel();
  }

  Future signup() async {
    setState(() {
      isSubmit = true;
    });
    print("Hello");

    http.Response response = await http.post(serverUrl + '/signup',
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({
          "first_name": this.widget.firstName,
          "last_name": this.widget.lastName,
          "mobileno": this.widget.phoneNumber,
          "email": this.widget.email,
          "password": this.widget.password,
          "otpVerified": true
        }));

    print(response.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await prefs.setString("token", parse['token']);
      setState(() {
        isSubmit = false;
        dataSubmitted = true;
        serverError = false;
      });
    } else if (response.statusCode == 409) {
      await prefs.setString("token", '');
      setState(() {
        isSubmit = false;
        serverError = false;
      });
    } else if (response.statusCode == 500) {
      await prefs.setString("token", '');
      setState(() {
        isSubmit = false;
        serverError = true;
      });
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
          return Container(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Check Internet Connection !",
                    style: TextStyle(fontSize: 15))
              ],
            ),
          ));
        }
        return child;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30.0),
              Text(
                "Please enter the 4-digit OTP",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              OTPFields(),
              const SizedBox(height: 20.0),
              Text(
                "Expiring in " +
                    "0" +
                    minute.toString() +
                    ":" +
                    seconds.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                child: Text(
                  "RESEND OTP",
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    minute = 0;
                    seconds = 59;
                  });
                  await resendOtp();
                },
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  padding: const EdgeInsets.all(16.0),
                  minimumSize: Size(200, 60),
                ),
                child: Text(
                  "Confirm",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                onPressed: () async {
                  otp = "" +
                      num1.toString() +
                      num2.toString() +
                      num3.toString() +
                      num4.toString();
                  print(otp);

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var sendOtp = prefs.getString("OTP");
                  print(sendOtp);
                  if (otp == sendOtp.toString()) {
                    await signup();
                    if (dataSubmitted == true) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.success,
                          confirmBtnColor: Colors.blue[800],
                          title: "Verification Successfully",
                          onConfirmBtnTap: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            pref.remove("OTP");
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => Login_Screen()),
                                (Route<dynamic> route) => false);
                          });
                    }
                  } else {
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.error,
                      confirmBtnColor: Colors.blue[800],
                      title: "Wrong otp",
                    );
                  }

                  // if (this.widget.otpNo == otp) {
                  //   CoolAlert.show(
                  //       context: context,
                  //       type: CoolAlertType.success,
                  //       confirmBtnColor: Colors.blue[800],
                  //       title: "Verification Successfully",
                  //       onConfirmBtnTap: () {
                  //         Navigator.of(context).pushAndRemoveUntil(
                  //             MaterialPageRoute(
                  //                 builder: (context) => Login_Screen()),
                  //             (Route<dynamic> route) => false);
                  //       });
                  // } else {
                  //   CoolAlert.show(
                  //       context: context,
                  //       type: CoolAlertType.error,
                  //       confirmBtnColor: Colors.blue[800],
                  //       title: "Wrong otp",
                  //       onConfirmBtnTap: () {
                  //         Navigator.of(context).pushAndRemoveUntil(
                  //             MaterialPageRoute(
                  //                 builder: (context) => Login_Screen()),
                  //             (Route<dynamic> route) => false);
                  //       });
                  // }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OTPFields extends StatefulWidget {
  const OTPFields({
    Key key,
  }) : super(key: key);

  @override
  _OTPFieldsState createState() => _OTPFieldsState();
}

class _OTPFieldsState extends State<OTPFields> {
  FocusNode pin2FN;
  FocusNode pin3FN;
  FocusNode pin4FN;
  final pinStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    pin2FN = FocusNode();
    pin3FN = FocusNode();
    pin4FN = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FN?.dispose();
    pin3FN?.dispose();
    pin4FN?.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  autofocus: true,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) {
                    nextField(value, pin2FN);
                    num1 = value;
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  focusNode: pin2FN,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) {
                    nextField(value, pin3FN);
                    num2 = value;
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  focusNode: pin3FN,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) {
                    nextField(value, pin4FN);
                    num3 = value;
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  focusNode: pin4FN,
                  style: pinStyle,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: inputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin4FN.unfocus();
                    }
                    num4 = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
