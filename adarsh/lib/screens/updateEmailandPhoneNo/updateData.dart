import 'dart:async';
import 'dart:convert';
import 'package:adarsh/screens/Login/components/login.dart';
import 'package:adarsh/screens/profile/userProfile.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:http/http.dart' as http;

Color blueColors = Colors.blue[900];
Color blueLightColors = Colors.blue[400];

class UpdateDataScreen extends StatefulWidget {
  final String email;
  final String phone;
  final String name;

  const UpdateDataScreen({Key key, this.email, this.phone, this.name})
      : super(key: key);

  @override
  _UpdateDataScreenState createState() => _UpdateDataScreenState();
}

class _UpdateDataScreenState extends State<UpdateDataScreen> {
  final formKey = GlobalKey<FormState>();
  bool isSubmit = false;
  TextEditingController phoneNumber;
  TextEditingController emailId;
  TextEditingController userName;
  String email;
  String phoneNo;
  bool isPassword = false;
  String password;
  String name;

  void initState() {
    super.initState();
    emailId = new TextEditingController(text: this.widget.email);
    userName = new TextEditingController(text: this.widget.name);
    phoneNumber = new TextEditingController(text: this.widget.phone);
    email = this.widget.email;
    phoneNo = this.widget.phone;
    name = this.widget.name;
  }

  Future update() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');

    var url = Uri.parse('http://www.metalmanauto.xyz:2078/update');
    http.Response response = await http.post(url,
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({"token": token, "password": password}));
    if (response.statusCode == 200) {
      showSuccess();
    } else if (response.statusCode == 503) {
      showSomethingWentWrong();
    }
  }

  showSuccess() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        onCancelBtnTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('token');
          prefs.remove('name');
          prefs.remove('isLogin');
          Future.delayed(Duration(milliseconds: 10), () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false);
          });
        },
        text: 'Data Updated Successfully!',
        onConfirmBtnTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('token');
          prefs.remove('name');
          prefs.remove('isLogin');
          Future.delayed(Duration(milliseconds: 10), () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false);
          });
        });
  }

  showSomethingWentWrong() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      title: "Oops...",
      text: "Sorry, something went wrong",
    );
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
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[900],
            Colors.blue[800],
            Colors.blue[400]
          ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeAnimation(
                        1,
                        Text(
                          "Update Data",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60))),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                        ),
                        FadeAnimation(
                            1.4,
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(225, 95, 27, .3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5))
                                  ]),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        controller: userName,
                                        enabled: false,
                                        decoration: InputDecoration(
                                            hintText: 'Name',
                                            prefixIcon: Icon(Icons.phone),
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        controller: phoneNumber,
                                        enabled: false,
                                        decoration: InputDecoration(
                                            hintText: 'Mobile Number',
                                            prefixIcon: Icon(Icons.phone),
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        controller: emailId,
                                        enableInteractiveSelection: false,
                                        enabled: false,
                                        decoration: InputDecoration(
                                            hintText: "Email",
                                            prefixIcon:
                                                Icon(Icons.email_outlined),
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        obscureText: isPassword,
                                        keyboardType: TextInputType.text,
                                        onChanged: (String value) {
                                          password = value;
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty ||
                                              value.length < 6) {
                                            return 'Password minimum length 6 required';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Password",
                                            prefixIcon: Icon(
                                              Icons.lock,
                                            ),
                                            suffix: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isPassword = !isPassword;
                                                });
                                              },
                                              child: Icon(
                                                isPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                            ),
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        isSubmit != false
                            ? new Container(
                                child: new Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: new Center(
                                        child: new CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor),
                                    ))),
                              )
                            : FadeAnimation(
                                1.6,
                                Container(
                                  height: 50,
                                  margin: EdgeInsets.symmetric(horizontal: 50),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.blue[800]),
                                  child: FlatButton(
                                    onPressed: () async {
                                      if (!(formKey.currentState.validate())) {
                                        return;
                                      } else {
                                        await update();
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "Update".toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateY").add(
          Duration(milliseconds: 500), Tween(begin: -30.0, end: 0.0),
          curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(0, animation["translateY"]), child: child),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  var btnText = "";
  var onClick;

  ButtonWidget({this.btnText, this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [blueColors, blueLightColors],
              end: Alignment.centerLeft,
              begin: Alignment.centerRight),
          borderRadius: BorderRadius.all(
            Radius.circular(102),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          btnText,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
