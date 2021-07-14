import 'dart:convert';

import 'package:adarsh/screens/Receipt/receipt.dart';
import 'package:adarsh/serverUrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaytmApp extends StatefulWidget {
  final String roomId;
  final String roomType;
  final String startingDay;
  final String endingDay;
  final int totalAmount;
  final int roomNumber;
  final String description;
  final String documentType;
  final String documentNumber;

  const PaytmApp(
      {Key key,
      this.roomId,
      this.roomType,
      this.startingDay,
      this.endingDay,
      this.totalAmount,
      this.roomNumber,
      this.description,
      this.documentType,
      this.documentNumber})
      : super(key: key);

  @override
  _PaytmAppState createState() => _PaytmAppState();
}

class _PaytmAppState extends State<PaytmApp> {
  @override
  void initState() {
    super.initState();
    getDetails();
  }

  String orderId;
  String txnToken;
  String result;
  Result obj;
  String email;
  String mobile;
  String userOrderID;

  Future<void> getDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.post(serverUrl + '/getDetails',
          headers: {'Content-Type': 'application/json;charset=UTF-8'},
          body: jsonEncode({"token": prefs.getString('token')}));
      if (response.statusCode == 200) {
        var parse = jsonDecode(response.body);
        print(parse);
        setState(() {
          email = parse['email'];
          mobile = parse['mobile'];
        });
        generateToken();
      }
    } catch (e) {}
  }

  Future<void> generateToken() async {
    // setState(() {
    //   isToke
    // });
    try {
      await getDetails();
      await http
          .post(Uri.parse(serverUrl + "/generateToken"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8'
              },
              body: jsonEncode({
                "amount": this.widget.totalAmount,
                "email": email,
                "mobile": mobile,
              }))
          .then((value) {
        var parse = jsonDecode(value.body);
        setState(() {
          txnToken = parse['txnToken'];
          orderId = parse['orderId'];
        });
        if (value.statusCode == 200 && txnToken != null) {
          startTransaction();
        }
      });
    } catch (e) {}
  }

  startTransaction() {
    try {
      AllInOneSdk.startTransaction("ycnaiy48639994765108", orderId,
              this.widget.totalAmount.toString(), txnToken, null, true, false)
          .then((value) {
        setState(() async {
          result = value.toString();
          obj = Result.fromJson(value);
          await bookRoom();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => Receipt(
                      roomType: this.widget.roomType,
                      endingDay: this.widget.endingDay,
                      orderId: userOrderID,
                      roomNumber: this.widget.roomNumber,
                      startingDay: this.widget.startingDay,
                      totalAmount: this.widget.totalAmount,
                      paymentOrderId: orderId,
                      paymentStatus: (obj.status == "TXN_SUCCESS")
                          ? "PAYMENT_SUCCESSFUL"
                          : (obj.status == "TXN_FAILURE")
                              ? "PAYMENT_FAILED"
                              : "PAYMENT_PENDING")),
              (Route<dynamic> route) => false);
        });
        print(obj);
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() async {
            result = onError.details;
            obj = Result.fromJson(result);
            await bookRoom();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Receipt(
                        roomType: this.widget.roomType,
                        endingDay: this.widget.endingDay,
                        orderId: userOrderID,
                        roomNumber: this.widget.roomNumber,
                        startingDay: this.widget.startingDay,
                        totalAmount: this.widget.totalAmount,
                        paymentOrderId: orderId,
                        paymentStatus: (obj.status == "TXN_SUCCESS")
                            ? "PAYMENT_SUCCESSFUL"
                            : (obj.status == "TXN_FAILURE")
                                ? "PAYMENT_FAILED"
                                : "PAYMENT_PENDING")),
                (Route<dynamic> route) => false);
          });
        } else {
          setState(() async {
            result = onError.toString();
            obj = Result.fromJson(result);
            await bookRoom();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Receipt(
                        roomType: this.widget.roomType,
                        endingDay: this.widget.endingDay,
                        orderId: userOrderID,
                        roomNumber: this.widget.roomNumber,
                        startingDay: this.widget.startingDay,
                        totalAmount: this.widget.totalAmount,
                        paymentOrderId: orderId,
                        paymentStatus: (obj.status == "TXN_SUCCESS")
                            ? "PAYMENT_SUCCESSFUL"
                            : (obj.status == "TXN_FAILURE")
                                ? "PAYMENT_FAILED"
                                : "PAYMENT_PENDING")),
                (Route<dynamic> route) => false);
          });
        }
      });
    } catch (err) {
      result = err.message;
    }
  }

  Future bookRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    http.Response response = await http.post(serverUrl + '/book_room',
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({
          "token": token,
          "roomId": widget.roomId,
          "startDate": widget.startingDay,
          "endDate": widget.endingDay,
          "Amount": widget.totalAmount,
          "documentName": widget.documentType,
          "documentType": widget.documentNumber,
          "roomType": widget.roomType,
          "roomNumber": widget.roomNumber,
          "paymentOrderId": orderId,
          "paymentStatus": (obj.status == "TXN_SUCCESS")
              ? "PAYMENT_SUCCESSFUL"
              : (obj.status == "TXN_FAILURE")
                  ? "PAYMENT_FAILED"
                  : "PAYMENT_PENDING",
        }));
    if (response.statusCode == 200) {
      var parse = jsonDecode(response.body);
      setState(() {
        userOrderID = parse["orderId"];
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text(
            'Do Not Refresh....',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    )));
  }
}

class Result {
  String status;
  String bankName;
  String payMode;
  String txnId;
  String bankTxnId;
  String rspMsg;
  String txnDate;

  Result(this.status, this.bankName, this.payMode, this.txnId, this.bankTxnId,
      this.rspMsg, this.txnDate);

  factory Result.fromJson(dynamic json) {
    return Result(
        json['STATUS'] as String,
        json['GATEWAYNAME'] as String,
        json['PAYMENTMODE'] as String,
        json['TXNID'] as String,
        json['BANKTXNID'] as String,
        json['RESPMSG'] as String,
        json['TXNDATE'] as String);
  }

  @override
  String toString() {
    return '{ ${this.status},${this.bankName}, ${this.payMode},${this.txnId},${this.bankTxnId},${this.rspMsg},${this.txnDate} }';
  }
}
