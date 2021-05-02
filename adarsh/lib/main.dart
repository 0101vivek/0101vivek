import 'package:adarsh/screens/ConfirmBookingandMakePayment/confirmBookingandMakePayment.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:adarsh/screens/updateEmailandPhoneNo/updateData.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  // debugPrintHitTestResults = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adarsh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[600],
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),
    );
  }
}
