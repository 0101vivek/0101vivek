import 'dart:async';
import 'dart:convert';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Color blueColors = Colors.blue[900];

class ConfirmOrderPage extends StatefulWidget {
  final String roomId;
  final String roomType;
  final String startingDay;
  final String endingDay;
  final int totalAmount;
  final int roomNumber;

  const ConfirmOrderPage({
    Key key,
    this.roomId,
    this.roomNumber,
    this.totalAmount,
    this.startingDay,
    this.endingDay,
    this.roomType,
  }) : super(key: key);

  @override
  _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  String documentNumber;
  String cashOnDelivey;
  String documentType = 'AdhaarCard';
  bool value = true;
  bool isSubmit = true;
  TextEditingController controller;
  final formKey = GlobalKey<FormState>();

  Future bookRoom() async {
    if (mounted) {
      setState(() {
        isSubmit = false;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    http.Response response =
        await http.post('http://192.168.0.100:3000/book_room',
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
              "roomIsStillChecking": false
            }));

    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Room Booked Successfully');
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
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
              "For Cancellation done prior 11 AM on the check-in date 100% Refundable \n\nFor Cancellation done post 11 AM on the check-in date Non Refundable",
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
          documentType == "Pan Card"
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
                            !RegExp(r"^[2-9]{1}[0-9]{11}").hasMatch(value)) {
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
              padding: EdgeInsets.all(8.0),
              width: double.infinity,
              child: Text("Payment Option".toUpperCase())),
          RadioListTile(
            groupValue: true,
            value: true,
            activeColor: blueColors,
            title: Text("Cash on Delivery"),
            onChanged: (value) {
              cashOnDelivey = value;
            },
          ),
          const SizedBox(height: 20.0),
          isSubmit == false
              ? new Container(
                  child: new Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new Center(
                          child: new CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor),
                      ))),
                )
              : SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: Colors.blue[900],
                    textColor: Colors.white,
                    child: Text(
                      "Confirm Now",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState.validate()) {
                        return;
                      } else {
                        bool roombookSuccess = await bookRoom();
                        if (roombookSuccess == true) {
                          var time = Timer(Duration(seconds: 2), () {});
                          time.cancel();
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.success,
                              title: "Room Booked Successfully",
                              onConfirmBtnTap: () {
                                var time = Timer(
                                    Duration(seconds: 5), () => print('done'));
                                time.cancel();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                    (Route<dynamic> route) => false);
                              });
                        } else if (roombookSuccess == false) {
                          var time = Timer(Duration(seconds: 2), () {});
                          time.cancel();
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Try after some time",
                              onConfirmBtnTap: () {
                                var time = Timer(
                                    Duration(seconds: 5), () => print('done'));
                                time.cancel();
                                Navigator.of(context).pop();
                              });
                        }
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
