// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// const PAYMENT_URL = "http://10.0.2.2:3000/paynow";

// const ORDER_DATA = {
//   "custID": "USER_1122334455",
//   "custEmail": "someemail@gmail.com",
//   "custPhone": "1234567890"
// };

// const STATUS_LOADING = "PAYMENT_LOADING";
// const STATUS_SUCCESSFUL = "PAYMENT_SUCCESSFUL";
// const STATUS_PENDING = "PAYMENT_PENDING";
// const STATUS_FAILED = "PAYMENT_FAILED";
// const STATUS_CHECKSUM_FAILED = "PAYMENT_CHECKSUM_FAILED";


// class PaymentScreen extends StatefulWidget {
//   final amount;
//   final orderCart;
//   PaymentScreen({this.amount, this.orderCart});

//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   WebViewController _webController;
//   bool _loadingPayment = true;
//   String _responseStatus = STATUS_LOADING;
//   String _paymentId;
//   String _orderId;
//   String _loadHTML(String phno, String email) {
//     return "<html> <body onload='document.f.submit();'> <form id='f' name='f' method='post' action='$PAYMENT_URL'><input type='hidden' name='orderID' value='ORDER_${DateTime.now().millisecondsSinceEpoch}'/>" +
//         "<input  type='hidden' name='name' value='${ORDER_DATA["custID"]}' />" +
//         "<input  type='hidden' name='amount' value='${widget.amount}' />" +
//         "<input type='hidden' name='email' value='${email}' />" +
//         "<input type='hidden' name='phone' value='${phno}' />" +
//         "</form> </body> </html>";
//   }

//   Order_post() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String token = prefs.getString("aniket");
//     print("widget.orderCart is ${widget.orderCart}");
//     var url = "http://10.0.2.2:3000/order_post";
//     final http.Response response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json;charset=UTF-8'},
//       body: jsonEncode({
//         "user": token,
//         "cart": widget.orderCart,
//         "status": _responseStatus,
//         "address": "sinnar",
//         "totle": widget.amount,
//         "paymentId": _paymentId,
//         "orderId": _orderId
//       }),
//     );
//   }

//   void getData() {
//     _webController.evaluateJavascript("document.body.innerText").then((data) {
//       var decodedJSON = jsonDecode(data);
//       Map<String, dynamic> responseJSON = jsonDecode(decodedJSON);
//       final checksumResult = responseJSON["status"];
//       final paytmResponse = responseJSON["data"];
//       _orderId = paytmResponse['ORDERID'];
//       _paymentId = paytmResponse['BANKTXNID'];
//       if (paytmResponse["STATUS"] == "TXN_SUCCESS") {
//         if (checksumResult == 0) {
//           _responseStatus = STATUS_SUCCESSFUL;
//         } else {
//           _responseStatus = STATUS_CHECKSUM_FAILED;
//         }
//       } else if (paytmResponse["STATUS"] == "TXN_FAILURE") {
//         _responseStatus = STATUS_FAILED;
//       }
//       if (_paymentId.isNotEmpty) {
//         Order_post();
//       }
//       this.setState(() {});
//     });
//   }

//   Future<Album1> futureAlbum1;
//   @override
//   // ignore: must_call_super
//   void initState() {
//     futureAlbum1 = fetchAlbum1();
//   }

//   @override
//   void dispose() {
//     _webController = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return SafeArea(
//       child: Scaffold(
//         body: Stack(
//           children: [
//             FutureBuilder<Album1>(
//               future: futureAlbum1,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return Container(
//                     width: size.width,
//                     height: size.height,
//                     child: WebView(
//                       // debuggingEnabled: true,
//                       javascriptMode: JavascriptMode.unrestricted,
//                       onWebViewCreated: (controller) {
//                         _webController = controller;
//                         _webController.loadUrl(new Uri.dataFromString(
//                                 _loadHTML(
//                                     snapshot.data.msg4, snapshot.data.msg2),
//                                 mimeType: 'text/html')
//                             .toString());
//                       },
//                       onPageFinished: (page) {
//                         if (page.contains("/paynow")) {
//                           if (_loadingPayment) {
//                             this.setState(() {
//                               _loadingPayment = false;
//                             });
//                           }
//                         }
//                         if (page.contains("/callback")) {
//                           getData();
//                         }
//                       },
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text("${snapshot.error}");
//                 }

//                 // By default, show a loading spinner.
//                 return CircularProgressIndicator();
//               },
//             ),
//             // Container(
//             //   width: size.width,
//             //   height: size.height,
//             //   child: WebView(
//             //     // debuggingEnabled: true,
//             //     javascriptMode: JavascriptMode.unrestricted,
//             //     onWebViewCreated: (controller) {
//             //       _webController = controller;
//             //       _webController.loadUrl(
//             //           new Uri.dataFromString(_loadHTML(), mimeType: 'text/html')
//             //               .toString());
//             //     },
//             //     onPageFinished: (page) {
//             //       if (page.contains("/paynow")) {
//             //         if (_loadingPayment) {
//             //           this.setState(() {
//             //             _loadingPayment = false;
//             //           });
//             //         }
//             //       }
//             //       if (page.contains("/callback")) {
//             //         getData();
//             //       }
//             //     },
//             //   ),
//             // ),
//             (_loadingPayment)
//                 ? Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : Center(),
//             (_responseStatus != STATUS_LOADING)
//                 ? Center(
//                     child: OrderStatusScreen(
//                         _responseStatus, _paymentId, _orderId))
//                 : Center()
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OrderStatusScreen extends StatefulWidget {
//   final _responseStatus;
//   final _paymentId;
//   final _orderId;
//   OrderStatusScreen(this._responseStatus, this._paymentId, this._orderId);

//   @override
//   _OrderStatusScreenState createState() => _OrderStatusScreenState();
// }

// class _OrderStatusScreenState extends State<OrderStatusScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var text = widget._responseStatus == STATUS_SUCCESSFUL
//         ? "Great!"
//         : widget._responseStatus == STATUS_FAILED
//             ? "OOPS!"
//             : "Oh Snap!";
//     var msg = widget._responseStatus == STATUS_SUCCESSFUL
//         ? "Thank you making the payment!"
//         : widget._responseStatus == STATUS_FAILED
//             ? "Payment was not successful, Please try again Later!"
//             : "Problem Verifying Payment, If you balance is deducted please contact our customer support and get your payment verified!";
//     Widget icondata = widget._responseStatus == STATUS_SUCCESSFUL
//         ? Icon(
//             Icons.favorite,
//             color: Colors.pink,
//             semanticLabel: 'Payment Done',
//             size: size.width * 0.20,
//           )
//         : widget._responseStatus == STATUS_FAILED
//             ? Icon(
//                 Icons.report_gmailerrorred_outlined,
//                 color: Colors.red,
//                 semanticLabel: 'Failed',
//                 size: size.width * 0.20,
//               )
//             : Icon(
//                 Icons.perm_phone_msg,
//                 color: Colors.blueGrey,
//                 semanticLabel: 'Failed',
//                 size: size.width * 0.20,
//               );

//     return Container(
//       color: Colors.white,
//       height: size.height,
//       width: size.width,
//       child: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               icondata,
//               SizedBox(
//                 height: 10,
//               ),
//               Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(text,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 25))),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 msg,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 30),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "Payment ID:" + widget._paymentId,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "Order ID:" + widget._orderId,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 DateFormat('dd-MM-yyyy hh:mm:a')
//                     .format(DateTime.now())
//                     .toString(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               MaterialButton(
//                   color: Colors.black,
//                   child: Text(
//                     "Close",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   onPressed: () {
//                     Navigator.popUntil(context, ModalRoute.withName("/"));
//                   })
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
