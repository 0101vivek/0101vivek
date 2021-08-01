import 'dart:async';
import 'dart:convert';
import 'package:adarsh/screens/ConfirmBookingandMakePayment/components/roundedContainer.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/PaytmGateway/paytmPayment.dart';
import 'package:adarsh/screens/Receipt/receipt.dart';
import 'package:adarsh/serverUrl.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color blueColors = Colors.blue[900];

class ConfirmOrderPage extends StatefulWidget {
  final String roomId;
  final String roomType;
  final String startingDay;
  final String endingDay;
  final int totalAmount;
  final int roomNumber;
  final String image;
  final String description;

  const ConfirmOrderPage({
    Key key,
    this.roomId,
    this.roomNumber,
    this.image,
    this.totalAmount,
    this.startingDay,
    this.description,
    this.endingDay,
    this.roomType,
  }) : super(key: key);

  @override
  _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  String documentNumber;
  String cashOnDelivey;
  int paymentOption = 0;
  String documentType = 'AdhaarCard';
  bool value = true;
  bool isSubmit = true;
  TextEditingController controller;
  String email;
  String mobile;
  String orderId;
  String txnToken;
  String result;
  Result obj;
  final formKey = GlobalKey<FormState>();
  bool isTokenCall = false;

  void initState() {
    super.initState();
    // if (isTokenCall) {
    //   doNotRefreshPage();
    // }
  }

  void dispose() {
    super.dispose();
  }

  Future checkRoomAvailable() async {
    try {
      http.Response response =
          await http.post(serverUrl + '/check_available_book_room',
              headers: {'Content-Type': 'application/json;charset=UTF-8'},
              body: jsonEncode({
                "roomId": widget.roomId,
              }));
      return response;
    } catch (e) {}
  }

  Future bookRoom() async {
    if (mounted) {
      setState(() {
        isSubmit = false;
      });
    }

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
          "documentName": documentType,
          "documentType": documentNumber,
          "roomType": widget.roomType,
          "roomNumber": widget.roomNumber,
          "paymentOrderId": null,
          "paymentStatus": "PAYMENT_PENDING",
          "image": this.widget.image
          // "totalGuest": widget.totalGuest,
          // "description": widget.description
        }));

    if (response.statusCode == 200) {
      var parse = jsonDecode(response.body);
      orderId = parse["orderId"];
      setState(() {
        isSubmit = true;
      });
      return true;
    } else if (response.statusCode == 503) {
      setState(() {
        isSubmit = true;
      });
      return false;
    }
  }

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    // showInSnackBar("Some text");
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
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Confirm Booking"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () {
                var time = Timer(Duration(seconds: 1), () => print('done'));
                time.cancel();
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back),
            ),
            backgroundColor: Colors.blue[900],
          ),
          body: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
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
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0, bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Total Amount",
                  style: Theme.of(context).textTheme.title,
                ),
                Text("Rs. " + this.widget.totalAmount.toString().toUpperCase(),
                    style: Theme.of(context).textTheme.title),
              ],
            ),
            const SizedBox(height: 30.0),
            Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.all(8.0),
                width: double.infinity,
                child: Text("Keep in mind".toUpperCase())),
            const SizedBox(height: 15.0),
            Container(
              width: double.infinity,
              child: Text(
                "For Cancellation done prior 11 AM on the check-in date 100 % Refundable \n\nFor Cancellation done post 11 AM on the check-in date Non Refundable",
                textAlign: TextAlign.justify,
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.all(8.0),
                width: double.infinity,
                child: Text("Select Document for Verification".toUpperCase())),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                Radio(
                  value: 'AdhaarCard',
                  groupValue: documentType,
                  onChanged: (value) {
                    setState(() {
                      documentType = 'AdhaarCard';
                    });
                  },
                  activeColor: blueColors,
                ),
                Text(
                  "Adhar Card",
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                Radio(
                  value: 'PanCard',
                  groupValue: documentType,
                  onChanged: (value) {
                    setState(() {
                      documentType = 'PanCard';
                    });
                  },
                  activeColor: blueColors,
                ),
                Text(
                  "Pan Card",
                  style: TextStyle(fontSize: 18.0),
                )
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                Radio(
                  value: 'LicenseId',
                  groupValue: documentType,
                  onChanged: (value) {
                    setState(() {
                      documentType = 'LicenseId';
                    });
                  },
                  activeColor: blueColors,
                ),
                Text(
                  "License Id",
                  style: TextStyle(fontSize: 18.0),
                )
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                    color: Colors.grey.shade200,
                    padding: EdgeInsets.all(8.0),
                    width: double.infinity,
                    child:
                        Text("Document detail for Verification".toUpperCase())),
              ],
            ),
            documentType == "PanCard"
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.09,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: controller,
                        onChanged: (String value) {
                          documentNumber = value;
                        },
                        validator: (String value) {
                          if (value.isEmpty ||
                              value.length != 10 ||
                              !RegExp(r"[A-Z]{5}[0-9]{4}[A-Z]{1}")
                                  .hasMatch(value)) {
                            return "Enter valid pan number";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Pan Number",
                          icon: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                : documentType == "LicenseId"
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.09,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: controller,
                            onChanged: (String value) {
                              documentNumber = value;
                            },
                            validator: (String value) {
                              if (value.isEmpty ||
                                  value.length != 16 ||
                                  !RegExp(r'^(([A-Z]{2}[0-9]{2})( )|([A-Z]{2}-[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$')
                                      .hasMatch(value)) {
                                return "Enter valid License number";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter License Number",
                              icon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.09,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: controller,
                            onChanged: (String value) {
                              documentNumber = value;
                            },
                            validator: (String value) {
                              if (value.isEmpty ||
                                  value.length != 12 ||
                                  !RegExp(r"^[2-9]{1}[0-9]{11}")
                                      .hasMatch(value)) {
                                return "Enter valid adhar number";
                              } else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Adhar Number",
                              icon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
            SizedBox(
              height: 20.0,
            ),
            Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.all(6.0),
                width: double.infinity,
                child: Text("Payment Option".toUpperCase())),
            RoundedContainer(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.indigo,
                ),
                title: Text("Paytm"),
                onTap: () async {
                  if (formKey.currentState.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Currently online payment option in not available'),
                    ));
                  } else {
                    return;
                  }

                  // http.Response response = await checkRoomAvailable();
                  // print(response.statusCode);
                  // if (formKey.currentState.validate() &&
                  //     response.statusCode == 200) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => PaytmApp(
                  // roomId: this.widget.roomId,
                  // image:this.widget.image,
                  //               roomType: this.widget.roomType,
                  //               startingDay: this.widget.startingDay,
                  //               endingDay: this.widget.endingDay,
                  //               description: this.widget.description,
                  //               totalAmount: this.widget.totalAmount,
                  //               roomNumber: this.widget.roomNumber,
                  //               documentNumber: documentNumber,
                  //               documentType: documentType,
                  //             )),
                  //   );
                  // } else {
                  //   return;
                  // }
                },
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            RoundedContainer(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(
                  Icons.money_sharp,
                  color: Colors.indigo,
                ),
                onTap: () async {
                  if (formKey.currentState.validate()) {
                    http.Response response = await checkRoomAvailable();
                    print(response.statusCode);
                    if (response.statusCode == 200) {
                      bool book_room = await bookRoom();
                      if (book_room == true) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: 'Room Booked successfully!',
                            onConfirmBtnTap: () {
                              Future.delayed(Duration(milliseconds: 1000), () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => Receipt(
                                              endingDay: this.widget.endingDay,
                                              orderId: orderId,
                                              roomNumber:
                                                  this.widget.roomNumber,
                                              roomType: this.widget.roomType,
                                              totalAmount:
                                                  this.widget.totalAmount,
                                              // totalGuest:
                                              //     this.widget.totalGuest,
                                              startingDay:
                                                  this.widget.startingDay,
                                              paymentOrderId: "Cash",
                                              paymentStatus: "PAYMENT_PENDING",
                                            )),
                                    (Route<dynamic> route) => false);
                              });
                            });
                      } else {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            title: "Oops...",
                            text: "Sorry, something went wrong",
                            onConfirmBtnTap: () {
                              Future.delayed(Duration(milliseconds: 1000), () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                    (Route<dynamic> route) => false);
                              });
                            });
                      }
                    } else {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          title: "Oops...",
                          text: "Sorry, something went wrong",
                          onConfirmBtnTap: () {
                            Future.delayed(Duration(milliseconds: 1000), () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                  (Route<dynamic> route) => false);
                            });
                          });
                    }
                  } else {
                    return;
                  }
                },
                title: Text("Cash"),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
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
