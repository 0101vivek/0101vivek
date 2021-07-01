import 'dart:convert';

import 'package:adarsh/screens/payment/edit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String orderId;
  Future<String> generateToken(String amount) async {
    print("Hii");
    http.Response response = await http.post(
      "http://192.168.0.102:3000/generateToken",
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );
    print(response);
    var parse = jsonDecode(response.body);
    setState(() {
      txnToken = parse['txnToken'];
      orderId = parse['orderId'];
    });
    if (txnToken != null) {
      setState(() {
        isApiCallInprogress = false;
      });
    }
  }

  bool isloading = true;
  var response;
  String mid = "hhmpXO40944790524496",
      custId = "Cust_12345678",
      amount = "22",
      txnToken,
      email,
      mobile;

  var result;
  bool isStaging = false;
  bool isApiCallInprogress = true;
  String callbackUrl =
      "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=";

  bool restrictAppInvoke = false;
  var res;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              SizedBox(height: 60),
              Container(
                margin: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    generateToken(amount);
                  },
                  child: Text('Fetch Token'),
                ),
              ),
              EditText(
                'Transaction Token',
                txnToken,
                isEnabled: false,
              ),
              Container(
                margin: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: isApiCallInprogress
                      ? null
                      : () {
                          _startTransaction();
                        },
                  child: Text('Start Transcation'),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                child: Text("Message : "),
              ),
              Container(
                child: Text(result.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startTransaction() async {
    if (txnToken.isEmpty) {
      return;
    }
    try {
      var response = AllInOneSdk.startTransaction(
          "ycnaiy48639994765108", orderId, amount, txnToken, null, true, false);
      response.then((value) {
        setState(() {
          result = value;
        });
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {
            result = onError.message + " \n  " + onError.details.toString();
          });
        } else {
          setState(() {
            result = onError.toString();
          });
        }
      });
    } catch (err) {
      result = err.message;
    }
  }
}
