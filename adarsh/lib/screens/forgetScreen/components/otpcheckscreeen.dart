import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
  final String phoneNo;

  const OTPPage({Key key, this.phoneNo}) : super(key: key);
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  int minute = 0;
  int seconds = 59;
  Timer time1;

  void initState() {
    super.initState();
    setUpTimedForOtp();
  }

  Future sendOTP() async {
    String data = generateOtp();
    print(data);
    try {
      http.Response response = await http.post(
        serverUrl + '/send_otp',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode({
          "mobile": this.widget.phoneNo,
          "name": null,
          "status": "Forget Password",
          "otp": data.toString()
        }),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("OTP", data);
    } catch (e) {}
  }

  showSomethingWentWrong() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      title: "Oops...",
      text: "Sorry, something went wrong",
    );
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

  navigatepasswordscreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetPassword(
                  phoneNo: this.widget.phoneNo,
                )),
      );
    });
  }

  showInvalidDataMessage() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      title: "Invalid Otp".toUpperCase(),
      confirmBtnColor: Colors.blue[800],
    );
  }

  setUpTimedForOtp() {
    time1 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (minute == 0 && seconds == 0) {
        clearOtp();
        time1.cancel();
      } else {
        setState(() {
          seconds = seconds - 1;
        });
      }
    });
  }

  void clearOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("OTP");
  }

  void dispose() {
    super.dispose();
    time1.cancel();
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
                    minute = 4;
                    seconds = 59;
                  });
                  setUpTimedForOtp();
                  await sendOTP();
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
                  var sendOTP = prefs.getString("OTP");
                  if (sendOTP.toString() == otp) {
                    navigatepasswordscreen();
                  } else {
                    showInvalidDataMessage();
                  }
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
                  onChanged: (String value) {
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
                  onChanged: (String value) {
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
                  onChanged: (String value) {
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
                  onChanged: (String value) {
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
