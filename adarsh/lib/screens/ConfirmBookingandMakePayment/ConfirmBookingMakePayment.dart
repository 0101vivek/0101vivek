// import 'dart:async';
// import 'dart:convert';
// import 'package:adarsh/screens/HomeBooking/homePage.dart';
// import 'package:cool_alert/cool_alert.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_offline/flutter_offline.dart';
// import 'package:http/http.dart' as http;
// import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Color blueColors = Colors.blue[900];

// class ConfirmOrderPage extends StatefulWidget {
//   final String roomId;
//   final String roomType;
//   final String startingDay;
//   final String endingDay;
//   final int totalAmount;
//   final int roomNumber;
//   final String description;

//   const ConfirmOrderPage({
//     Key key,
//     this.roomId,
//     this.roomNumber,
//     this.totalAmount,
//     this.startingDay,
//     this.description,
//     this.endingDay,
//     this.roomType,
//   }) : super(key: key);

//   @override
//   _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
// }

// class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
//   String documentNumber;
//   String cashOnDelivey;
//   int paymentOption = 0;
//   String documentType = 'AdhaarCard';
//   bool value = true;
//   bool isSubmit = true;
//   TextEditingController controller;
//   String email;
//   String mobile;
//   String orderId;
//   String txnToken;
//   String result;
//   final formKey = GlobalKey<FormState>();

//   void initState() {
//     super.initState();
//   }

//   void dispose() {
//     super.dispose();
//   }

//   Future checkRoomAvailable() async {
//     try {
//       http.Response response =
//           await http.post('http://192.168.0.102:3000/check_available_book_room',
//               headers: {'Content-Type': 'application/json;charset=UTF-8'},
//               body: jsonEncode({
//                 "roomId": widget.roomId,
//               }));
//       return response;
//     } catch (e) {}
//   }

//   Future<void> getDetails() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       http.Response response = await http.post(
//           'http://192.168.0.102:3000/getDetails',
//           headers: {'Content-Type': 'application/json;charset=UTF-8'},
//           body: jsonEncode({"token": prefs.getString('token')}));
//       if (response.statusCode == 200) {
//         var parse = jsonDecode(response.body);
//         print(parse);
//         email = parse['email'];
//         mobile = parse['mobile'];
//       }
//     } catch (e) {}
//   }

//   Future<void> generateToken() async {
//     try {
//       await getDetails();
//       await http
//           .post(Uri.parse("http://192.168.0.102:3000/generateToken"),
//               headers: <String, String>{
//                 'Content-Type': 'application/json; charset=UTF-8'
//               },
//               body: jsonEncode({
//                 "amount": this.widget.totalAmount,
//                 "email": email,
//                 "mobile": mobile,
//                 "paymentMode": paymentOption
//               }))
//           .then((value) {
//         var parse = jsonDecode(value.body);
//         txnToken = parse['txnToken'];
//         orderId = parse['orderId'];
//       });
//     } catch (e) {}
//   }

//   Future<void> _startTransaction() async {
//     setState(() {
//       isSubmit = false;
//     });
//     await generateToken();
//     if (txnToken.isEmpty) {
//       return;
//     }
//     try {
//       var response = AllInOneSdk.startTransaction(
//           "ycnaiy48639994765108",
//           orderId,
//           this.widget.totalAmount.toString(),
//           txnToken,
//           null,
//           true,
//           false);
//       response.then((value) {
//         print(value);
//         setState(() {
//           isSubmit = true;
//         });
//       }).catchError((onError) {
//         if (onError is PlatformException) {
//           setState(() {
//             result = onError.message + " \n  " + onError.details.toString();
//           });
//         } else {
//           setState(() {
//             result = onError.toString();
//           });
//         }
//       });
//     } catch (err) {
//       result = err.message;
//     }
//   }

//   Future bookRoom() async {
//     if (mounted) {
//       setState(() {
//         isSubmit = false;
//       });
//     }

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString('token');

//     http.Response response =
//         await http.post('http://192.168.0.102:3000/book_room',
//             headers: {'Content-Type': 'application/json;charset=UTF-8'},
//             body: jsonEncode({
//               "token": token,
//               "roomId": widget.roomId,
//               "startDate": widget.startingDay,
//               "endDate": widget.endingDay,
//               "Amount": widget.totalAmount,
//               "documentName": documentType,
//               "documentType": documentNumber,
//               "roomType": widget.roomType,
//               "roomNumber": widget.roomNumber,
//               "description": widget.description
//             }));

//     if (response.statusCode == 200) {
//       setState(() {
//         isSubmit = true;
//       });
//       return true;
//     } else if (response.statusCode == 503) {
//       setState(() {
//         isSubmit = true;
//       });
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return OfflineBuilder(
//       debounceDuration: Duration.zero,
//       connectivityBuilder: (
//         BuildContext context,
//         ConnectivityResult connectivity,
//         Widget child,
//       ) {
//         if (connectivity == ConnectivityResult.none) {
//           return Scaffold(
//               body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 20),
//                 Text("Check Internet Connection !",
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.black,
//                         backgroundColor: Colors.white))
//               ],
//             ),
//           ));
//         }
//         return child;
//       },
//       child: WillPopScope(
//         onWillPop: () async => false,
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text("Confirm Booking"),
//             centerTitle: true,
//             automaticallyImplyLeading: false,
//             leading: GestureDetector(
//               onTap: () {
//                 var time = Timer(Duration(seconds: 1), () => print('done'));
//                 time.cancel();
//                 Navigator.of(context).pop();
//               },
//               child: Icon(Icons.arrow_back),
//             ),
//             backgroundColor: Colors.blue[900],
//           ),
//           body: _buildBody(context),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return OfflineBuilder(
//       debounceDuration: Duration.zero,
//       connectivityBuilder: (
//         BuildContext context,
//         ConnectivityResult connectivity,
//         Widget child,
//       ) {
//         if (connectivity == ConnectivityResult.none) {
//           return Scaffold(
//               body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 20),
//                 Text("Check Internet Connection !",
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.black,
//                         backgroundColor: Colors.white))
//               ],
//             ),
//           ));
//         }
//         return child;
//       },
//       child: SingleChildScrollView(
//         padding:
//             EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0, bottom: 10.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Text(
//                   "Total Amount",
//                   style: Theme.of(context).textTheme.title,
//                 ),
//                 Text("Rs. " + this.widget.totalAmount.toString().toUpperCase(),
//                     style: Theme.of(context).textTheme.title),
//               ],
//             ),
//             const SizedBox(height: 30.0),
//             Container(
//                 color: Colors.grey.shade200,
//                 padding: EdgeInsets.all(8.0),
//                 width: double.infinity,
//                 child: Text("Keep in mind".toUpperCase())),
//             const SizedBox(height: 15.0),
//             Container(
//               width: double.infinity,
//               child: Text(
//                 "For Cancellation done prior 11 AM on the check-in date 102% Refundable \n\nFor Cancellation done post 11 AM on the check-in date Non Refundable",
//                 textAlign: TextAlign.justify,
//                 style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.0),
//               ),
//             ),
//             SizedBox(
//               height: 20.0,
//             ),
//             Container(
//                 color: Colors.grey.shade200,
//                 padding: EdgeInsets.all(8.0),
//                 width: double.infinity,
//                 child: Text("Select Document for Verification".toUpperCase())),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 'AdhaarCard',
//                   groupValue: documentType,
//                   onChanged: (value) {
//                     setState(() {
//                       documentType = 'AdhaarCard';
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Adhar Card",
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ],
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 'PanCard',
//                   groupValue: documentType,
//                   onChanged: (value) {
//                     setState(() {
//                       documentType = 'PanCard';
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Pan Card",
//                   style: TextStyle(fontSize: 18.0),
//                 )
//               ],
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 'LicenseId',
//                   groupValue: documentType,
//                   onChanged: (value) {
//                     setState(() {
//                       documentType = 'LicenseId';
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "License Id",
//                   style: TextStyle(fontSize: 18.0),
//                 )
//               ],
//             ),
//             Column(
//               children: <Widget>[
//                 Container(
//                     color: Colors.grey.shade200,
//                     padding: EdgeInsets.all(8.0),
//                     width: double.infinity,
//                     child:
//                         Text("Document detail for Verification".toUpperCase())),
//               ],
//             ),
//             documentType == "PanCard"
//                 ? Container(
//                     margin: EdgeInsets.symmetric(vertical: 10),
//                     padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     height: MediaQuery.of(context).size.height * 0.09,
//                     decoration: BoxDecoration(
//                       color: Colors.white12,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Form(
//                       key: formKey,
//                       child: TextFormField(
//                         keyboardType: TextInputType.text,
//                         controller: controller,
//                         onChanged: (String value) {
//                           documentNumber = value;
//                         },
//                         validator: (String value) {
//                           if (value.isEmpty ||
//                               value.length != 10 ||
//                               !RegExp(r"[A-Z]{5}[0-9]{4}[A-Z]{1}")
//                                   .hasMatch(value)) {
//                             return "Enter valid pan number";
//                           } else {
//                             return null;
//                           }
//                         },
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                           hintText: "Enter Pan Number",
//                           icon: Icon(
//                             Icons.person,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 : documentType == "LicenseId"
//                     ? Container(
//                         margin: EdgeInsets.symmetric(vertical: 10),
//                         padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
//                         width: MediaQuery.of(context).size.width * 0.9,
//                         height: MediaQuery.of(context).size.height * 0.09,
//                         decoration: BoxDecoration(
//                           color: Colors.white12,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Form(
//                           key: formKey,
//                           child: TextFormField(
//                             controller: controller,
//                             onChanged: (String value) {
//                               documentNumber = value;
//                             },
//                             validator: (String value) {
//                               if (value.isEmpty ||
//                                   value.length != 16 ||
//                                   !RegExp(r'^(([A-Z]{2}[0-9]{2})( )|([A-Z]{2}-[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$')
//                                       .hasMatch(value)) {
//                                 return "Enter valid License number";
//                               } else {
//                                 return null;
//                               }
//                             },
//                             keyboardType: TextInputType.text,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Enter License Number",
//                               icon: Icon(
//                                 Icons.person,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : Container(
//                         margin: EdgeInsets.symmetric(vertical: 10),
//                         padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
//                         width: MediaQuery.of(context).size.width * 0.9,
//                         height: MediaQuery.of(context).size.height * 0.09,
//                         decoration: BoxDecoration(
//                           color: Colors.white12,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Form(
//                           key: formKey,
//                           child: TextFormField(
//                             controller: controller,
//                             onChanged: (String value) {
//                               documentNumber = value;
//                             },
//                             validator: (String value) {
//                               if (value.isEmpty ||
//                                   value.length != 12 ||
//                                   !RegExp(r"^[2-9]{1}[0-9]{11}")
//                                       .hasMatch(value)) {
//                                 return "Enter valid adhar number";
//                               } else {
//                                 return null;
//                               }
//                             },
//                             keyboardType: TextInputType.text,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Enter Adhar Number",
//                               icon: Icon(
//                                 Icons.person,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//             SizedBox(
//               height: 20.0,
//             ),
//             Container(
//                 color: Colors.grey.shade200,
//                 padding: EdgeInsets.all(6.0),
//                 width: double.infinity,
//                 child: Text("Payment Option".toUpperCase())),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 0,
//                   groupValue: paymentOption,
//                   onChanged: (value) {
//                     setState(() {
//                       paymentOption = 0;
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Upi",
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ],
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 1,
//                   groupValue: paymentOption,
//                   onChanged: (value) {
//                     setState(() {
//                       paymentOption = 1;
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Net Banking",
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ],
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 2,
//                   groupValue: paymentOption,
//                   onChanged: (value) {
//                     setState(() {
//                       paymentOption = 2;
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Credit Card",
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ],
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 3,
//                   groupValue: paymentOption,
//                   onChanged: (value) {
//                     setState(() {
//                       paymentOption = 3;
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Debit Card",
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ],
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 4,
//                   groupValue: paymentOption,
//                   onChanged: (value) {
//                     setState(() {
//                       paymentOption = 4;
//                     });
//                   },
//                   activeColor: blueColors,
//                 ),
//                 Text(
//                   "Cash On Delivery",
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             isSubmit == false
//                 ? new Container(
//                     child: new Padding(
//                         padding: const EdgeInsets.all(5.0),
//                         child: new Center(
//                             child: new CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation(
//                               Theme.of(context).primaryColor),
//                         ))),
//                   )
//                 : SizedBox(
//                     width: double.infinity,
//                     child: RaisedButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30.0)),
//                       color: Colors.blue[900],
//                       textColor: Colors.white,
//                       child: Text(
//                         "Confirm Now",
//                         style: TextStyle(fontWeight: FontWeight.normal),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 16.0,
//                         horizontal: 32.0,
//                       ),
//                       onPressed: () async {
//                         await _startTransaction();
//                       },
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
