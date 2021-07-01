import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/Login/components/login.dart';
import 'package:adarsh/screens/Receipt/receipt.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:adarsh/screens/payment/paymentScreen.dart';
import 'package:adarsh/screens/roomDetails/roomDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // debugPrintHitTestResults = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final bool isLogged = await checkLogging();
  runApp(MyApp(home: isLogged == true ? HomePage() : WelcomeScreen()));
  // runApp(MyApp(home: WelcomeScreen()));
}

Future<bool> checkLogging() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var log = prefs.getBool('isLogin');
  print(log);
  return log == null ? false : log;
}


class MyApp extends StatelessWidget {
  final Widget home;
  MyApp({this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Adarsh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue[600],
          scaffoldBackgroundColor: Colors.white,
        ),
        home: home);
  }
}
