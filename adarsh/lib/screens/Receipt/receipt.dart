import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:flutter/material.dart';

class Receipt extends StatefulWidget {
  const Receipt(
      {Key key,
      this.roomType,
      this.startingDay,
      this.endingDay,
      this.totalAmount,
      this.orderId,
      this.roomNumber,
      this.totalGuest})
      : super(key: key);

  final String roomType;
  final String startingDay;
  final String endingDay;
  final int totalAmount;
  final int roomNumber;
  final int totalGuest;
  final String orderId;
  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  @override
  List month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateTime startdate = DateTime.parse(this.widget.startingDay.toString());
    DateTime enddate = DateTime.parse(this.widget.endingDay.toString());
    print(enddate.month);
    print(enddate.day);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
      },
      child: Scaffold(
          body: Container(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: size.height / 10),
              Row(children: <Widget>[
                Text(
                  "Order ID : ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20),
                ),
                Text(
                  this.widget.orderId ?? 'null',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ]),
              SizedBox(height: 50),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20.0),
                child: Table(
                  // border: TableBorder.all(color: Colors.black),
                  border: TableBorder.symmetric(
                      inside: BorderSide(width: 2, color: Colors.grey[200])),
                  children: [
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('Room Number')),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(this.widget.roomNumber.toString())),
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('Room Type')),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(this.widget.roomType.toString())),
                    ]),
                    // TableRow(children: [
                    //   Container(
                    //     padding: EdgeInsets.all(8.0),
                    //     child: Container(
                    //         alignment: Alignment.center,
                    //         child: Text('Number Of Guest')),
                    //   ),
                    //   Container(
                    //       padding: EdgeInsets.all(8.0),
                    //       alignment: Alignment.center,
                    //       child: Text(this.widget.totalGuest.toString())),
                    // ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('Check In Date')),
                      ),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8.0),
                          child: Text(startdate.day.toString() +
                              " " +
                              month[startdate.month - 1] +
                              " from 11 AM")),
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('Check Out Date')),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(enddate.day.toString() +
                              " " +
                              month[enddate.month - 1] +
                              " till 12 PM")),
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('Total Amount')),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(this.widget.totalAmount.toString())),
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('Payment Status')),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text("Pending...")),
                    ]),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                child: Text(
                  "Regards Zep,",
                  textAlign: TextAlign.end,
                ),
              ),
              SizedBox(height: 25),
              Container(
                child: Text(
                  "Thank You For Your Order!!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 80),
              SizedBox(
                width: double.maxFinite,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: Colors.blue[900],
                    textColor: Colors.white,
                    child: Text(
                      "Return To Home",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false);
                    }),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
