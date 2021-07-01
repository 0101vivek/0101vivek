import 'dart:async';
import 'dart:convert';
import 'package:adarsh/screens/forgetScreen/components/resetPassword.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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

String otp = null;

class OTPPage extends StatefulWidget {
  final String email;
  final String phoneNo;

  const OTPPage({Key key, this.email, this.phoneNo}) : super(key: key);
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  int minute = 4;
  int seconds = 59;
  Timer time1;

  void initState() {
    super.initState();
    setUpTimedForOtp();
  }

  Future resendOtp() async {
    try {
      var url = "https://vanillacode.tech/resend_otp";
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode(
            {'email': this.widget.email, 'phoneNo': this.widget.phoneNo}),
      );

      if (response.statusCode == 200) {
        minute = 4;
        seconds = 59;
        otp = null;
        time1.cancel();
        setUpTimedForOtp();
      } else if (response.statusCode == 500) {
        showSomethingWentWrong();
      }
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

  Future validateOtp() async {
    try {
      print(otp);
      var url = "https://vanillacode.tech/verify_otp";
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode({
          'email': this.widget.email,
          'phoneNo': this.widget.phoneNo,
          "otp": otp
        }),
      );

      if (response.statusCode == 200) {
        navigatepasswordscreen();
      } else if (response.statusCode == 404) {
        showInvalidDataMessage();
      } else if (response.statusCode == 500) {
        showSomethingWentWrong();
      }
    } catch (e) {}
  }

  navigatepasswordscreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetPassword(
                  email: this.widget.email,
                  phoneNo: this.widget.phoneNo,
                )),
      );
    });
  }

  showInvalidDataMessage() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      title: "Wrong Otp".toUpperCase(),
      confirmBtnColor: Colors.blue[800],
    );
  }

  setUpTimedForOtp() {
    time1 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (minute == 0 && seconds == 0) {
        time1.cancel();
      } else if (seconds == 0) {
        setState(() {
          seconds = 59;
          minute = minute - 1;
        });
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
                  await validateOtp();
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
                    otp = value;
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
                    otp = otp + value;
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
                    otp = otp + value;
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
                    otp = otp + value;
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
