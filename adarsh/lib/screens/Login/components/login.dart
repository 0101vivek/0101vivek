import 'dart:async';
import 'dart:convert';
import 'package:adarsh/modals/userLogin.dart';
import 'package:adarsh/screens/HomeBooking/homePage.dart';
import 'package:adarsh/screens/SignUp/signupscreen.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:adarsh/screens/forgetScreen/components/_forgetScreen.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  LoginModel model = new LoginModel();
  bool isSubmit = false;
  final formKey = GlobalKey<FormState>();
  bool isPassword = true;
  String name;
  String msg;

  Future login() async {
    setState(() {
      isSubmit = true;
    });
    var url = "http://192.168.0.100:3000/login";
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonEncode({
        'email': model.email,
        'password': model.password,
      }),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);

    if (response.statusCode == 404) {
      await prefs.setString('token', "");
      setState(() {
        msg = parse['msg'];
      });
    } else if (response.statusCode == 409) {
      await prefs.setString('token', "");
      setState(() {
        msg = parse['msg'];
      });
    } else if (response.statusCode == 201) {
      await prefs.setString('token', parse['token']);
      setState(() {
        name = parse['name'];
        msg = parse['msg'];
      });
    }
    setState(() {
      isSubmit = false;
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
            (Route<dynamic> route) => false);
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
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    FadeAnimation(
                        1.3,
                        Text(
                          "Welcome Back",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
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
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: (String value) {
                                          model.email = value;
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty ||
                                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                  .hasMatch(value)) {
                                            return 'Enter a valid Email!';
                                          }
                                          return null;
                                        },
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
                                          model.password = value;
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty ||
                                                  value.length <
                                                      8 /*||
                      !RegExp(r'^(?=.*?[a-z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                          .hasMatch(value)*/
                                              ) {
                                            return 'Enter valid password';
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
                          height: 40,
                        ),
                        SizedBox(
                          height: 20,
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
                                      try {
                                        if (formKey.currentState.validate()) {
                                          await login();
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          String token =
                                              prefs.getString("token");
                                          print(token);
                                          if (token != "") {
                                            var time = Timer(
                                                Duration(seconds: 3),
                                                () => "done");
                                            time.cancel();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(name: name)),
                                            );
                                          } else {
                                            CoolAlert.show(
                                                context: context,
                                                type: CoolAlertType.error,
                                                title: "Error",
                                                text: msg,
                                                onConfirmBtnTap: () {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LoginScreen()),
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                });
                                          }
                                        } else {
                                          return;
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                            1.5,
                            InkWell(
                              onTap: () {
                                var time = Timer(Duration(seconds: 2), () {});
                                time.cancel();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => ForgetScreen()),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                            1.5,
                            InkWell(
                              onTap: () {
                                var time = Timer(Duration(seconds: 2), () {});
                                time.cancel();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
                                );
                              },
                              child: Text(
                                "Don't Have an Account ? Sign Up",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              )),
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

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({
//     Key key,
//   }) : super(key: key);

//   @override
//   _BodyState createState() => _BodyState();
// }

// class _BodyState extends State<LoginScreen> {
//   bool isSubmit = false;
//   LoginModel model = new LoginModel();
//   final _formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return BackGround(
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Text(
//               //   "LOGIN",
//               //   style: TextStyle(
//               //       fontWeight: FontWeight.bold,
//               //       fontSize: 25,
//               //       letterSpacing: 2,
//               //       color: KPrimaryColor),
//               // ),
//               SizedBox(height: size.height * 0.03),
//               SizedBox(height: size.height * 0.03),
//               RoundedInputField(
//                   hintText: 'Email',
//                   onChanged: (String value) {
//                     model.email = value;
//                   },
//                   icon: Icons.email_outlined,
//                   inputType: TextInputType.emailAddress,
//                   validator: (String value) {
//                     if (value.isEmpty ||
//                         !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                             .hasMatch(value)) {
//                       return 'Enter a valid Email!';
//                     }
//                     return null;
//                   }),
//               RoundPasswordField(
//                 onChanged: (String value) {
//                   model.password = value;
//                 },
//                 inputType: TextInputType.text,
//                 validator: (String value) {
//                   if (value.isEmpty ||
//                           value.length <
//                               8 /*||
//                     !RegExp(r'^(?=.*?[a-z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
//                         .hasMatch(value)*/
//                       ) {
//                     return 'Enter valid password';
//                   }
//                 },
//               ),
//               isSubmit != false
//                   ? new Container(
//                       child: new Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: new Center(
//                               child: new CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation(
//                                 Theme.of(context).primaryColor),
//                           ))),
//                     )
//                   : RoundButton(
//                       text: "LOGIN",
//                       onpresed: () async {
//                         try {
//                           if (_formKey.currentState.validate()) {
//                             await login();
//                             SharedPreferences prefs =
//                                 await SharedPreferences.getInstance();
//                             String token = prefs.getString("token");
//                             print(token);
//                             String id = prefs.getString("id");
//                             String msg = prefs.getString("msg");
//                             print(msg);
//                             if (token != "") {
//                               await prefs.setString('token', token);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => HomePage(
//                                         name: prefs.getString('name'))),
//                               );
//                             } else {
//                               CoolAlert.show(
//                                   context: context,
//                                   type: CoolAlertType.error,
//                                   title: "Error",
//                                   text: msg,
//                                   onConfirmBtnTap: () {
//                                     Navigator.of(context).pop();
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 LoginScreen()));
//                                   });
//                             }
//                           } else {
//                             return;
//                           }
//                         } catch (e) {
//                           print(e);
//                         }
//                       }),
//               SizedBox(height: size.height * 0.03),
//               AlreadyHaveAccountCheck(
//                 pressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignUpScreen()),
//                   );
//                 },
//               ),
//               SizedBox(
//                 height: 8,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   new InkWell(
//                     child: Text(
//                       "Forgot Password?",
//                       style: TextStyle(
//                           color: KPrimaryColor, fontWeight: FontWeight.bold),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => ForgetScreen()),
//                       );
//                     },
//                   )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future login() async {
//     setState(() {
//       isSubmit = true;
//     });
//     var url = "http://192.168.0.102:3000/login";
//     final http.Response response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json;charset=UTF-8',
//       },
//       body: jsonEncode({
//         'email': model.email,
//         'password': model.password,
//       }),
//     );

//     print(response.statusCode);
//     // print(response.body);

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var parse = jsonDecode(response.body);
//     // print(parse);

//     // print(parse['name']);
//     if (response.statusCode == 404) {
//       await prefs.setString('msg', "User not found");
//       await prefs.setString('token', "");
//     } else if (response.statusCode == 409) {
//       await prefs.setString('msg', " Invalid data");
//       await prefs.setString('token', "");
//     } else if (response.statusCode == 201) {
//       await prefs.setString('msg', "User Login Successfully");
//       await prefs.setString('token', parse['token']);
//       await prefs.setString('id', parse["id"]);
//       await prefs.setString('phone', parse["phone"]);
//       print(parse['id']);
//       await prefs.setString('name', parse["name"]);
//     }
//     setState(() {
//       isSubmit = false;
//     });
//   }
// }
