import 'dart:async';
import 'dart:convert';

import 'package:adarsh/modals/userSignup.dart';
import 'package:adarsh/screens/Login/login_screen.dart';
import 'package:adarsh/screens/Welcome/welcome_screen.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:http/http.dart' as http;

Color blueColors = Colors.blue[900];
Color blueLightColors = Colors.blue[400];

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  Model model = new Model();
  String radioButtonVal = 'N';
  bool isSubmit = false;

  Future signup() async {
    setState(() {
      isSubmit = true;
    });
    print(model.firstName);
    var url = Uri.parse('http://192.168.0.100:3000/signup');
    http.Response response = await http.post(url,
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({
          "first_name": model.firstName,
          "last_name": model.lastName,
          "mobileno": model.phoneNumber,
          "email": model.email,
          "password": model.password
        }));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await prefs.setString("token", parse['token']);
      setState(() {
        isSubmit = false;
      });
    } else {
      await prefs.setString("token", '');
      setState(() {
        isSubmit = false;
      });
    }
  }

  voidCheckEmploye({String isEmployee}) {
    if (isEmployee == 'Y') {
      return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]))),
        child: TextFormField(
          keyboardType: TextInputType.text,
          onChanged: (String value) {
            // model.email = value;
          },
          validator: (String value) {
            if (value
                    .isEmpty /*||
                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)*/
                ) {
              return 'Enter a valid Employee Id';
            }
            return null;
          },
          decoration: InputDecoration(
              hintText: "Employee Id",
              prefixIcon: Icon(Icons.account_circle_sharp),
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
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
                          "Sign Up",
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
                                        keyboardType: TextInputType.text,
                                        onChanged: (String value) {
                                          model.firstName = value;
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty ||
                                              !RegExp(r"^[a-zA-Z]")
                                                  .hasMatch(value)) {
                                            return 'Enter a valid First Name!';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: "First Name",
                                            prefixIcon: Icon(
                                                Icons.account_circle_sharp),
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
                                        keyboardType: TextInputType.text,
                                        onChanged: (String value) {
                                          model.lastName = value;
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty ||
                                              !RegExp(r"^[a-zA-Z]")
                                                  .hasMatch(value)) {
                                            return 'Enter a valid Last Name!';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Last Name",
                                            prefixIcon: Icon(
                                                Icons.account_circle_sharp),
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
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: (String value) {
                                          model.phoneNumber = value;
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty ||
                                              value.length < 10 ||
                                              !RegExp(r"^[0-9]")
                                                  .hasMatch(value)) {
                                            return 'Enter a valid Mobile No';
                                          }
                                          return null;
                                        },
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
                                        obscureText: true,
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
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            'Are You Employee of the MetalMan?',
                                            style: new TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[900]),
                                          ),
                                          ButtonBar(
                                            alignment: MainAxisAlignment.center,
                                            children: [
                                              Radio(
                                                value: 'Y',
                                                groupValue: radioButtonVal,
                                                onChanged: (value) {
                                                  setState(() {
                                                    radioButtonVal = 'Y';
                                                  });
                                                },
                                                activeColor: blueColors,
                                              ),
                                              Text("Yes"),
                                              Radio(
                                                value: 'N',
                                                groupValue: radioButtonVal,
                                                onChanged: (value) {
                                                  setState(() {
                                                    radioButtonVal = 'N';
                                                  });
                                                },
                                                activeColor: blueColors,
                                              ),
                                              Text("No")
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    voidCheckEmploye(
                                        isEmployee: radioButtonVal),
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
                                        await signup();
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String token = prefs.getString("token");
                                        if (token != '') {
                                          var time = Timer(
                                              Duration(seconds: 2), () {});
                                          time.cancel();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Login_Screen()));
                                        } else {
                                          var time = Timer(
                                              Duration(seconds: 2), () {});
                                          time.cancel();
                                          CoolAlert.show(
                                              context: context,
                                              type: CoolAlertType.error,
                                              title: "User already registered",
                                              onConfirmBtnTap: () {
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Login_Screen()),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              });
                                        }
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "Sign Up",
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
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => Login_Screen()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Text(
                                "Already have an account ? Sign In",
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
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

class HeaderContainer extends StatelessWidget {
  var text = "Signin";

  HeaderContainer(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [blueColors, blueLightColors],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60))),
      child: Stack(
        children: <Widget>[
          Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 30),
              )),
        ],
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
            Radius.circular(100),
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

// import 'dart:convert';
// import 'dart:core';
// import 'package:adarsh/components/already_have_Account_Check.dart';
// import 'package:adarsh/components/round_buttons.dart';
// import 'package:adarsh/components/round_password_field.dart';
// import 'package:adarsh/components/rounded_input_field.dart';
// import 'package:adarsh/constant.dart';
// import 'package:adarsh/modals/userSignup.dart';
// import 'package:adarsh/screens/Login/login_screen.dart';
// import 'package:adarsh/screens/SignUp/Components/background.dart';
// import 'package:cool_alert/cool_alert.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class Body extends StatefulWidget {
//   @override
//   _BodyState createState() => _BodyState();
// }

// class _BodyState extends State<Body> {
//   String radioButtonVal = 'N';
//   final _formKey = GlobalKey<FormState>();
//   bool _isHidden = true;
//   bool isSubmit = false;
//   Model model = new Model();

//   @override
//   Widget build(BuildContext context) {
//     return BackGround(
//         child: SingleChildScrollView(
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             RoundedInputField(
//                 hintText: 'First Name',
//                 onChanged: (value) {
//                   model.firstName = value;
//                 },
//                 icon: Icons.account_circle_sharp,
//                 inputType: TextInputType.text,
//                 validator: (String value) {
//                   if (value.isEmpty || !RegExp(r"^[a-zA-Z]").hasMatch(value)) {
//                     return 'Enter a valid First Name!';
//                   }
//                   return null;
//                 }),
//             RoundedInputField(
//                 hintText: 'Last Name',
//                 onChanged: (value) {
//                   model.lastName = value;
//                 },
//                 icon: Icons.account_circle_sharp,
//                 inputType: TextInputType.text,
//                 validator: (String value) {
//                   if (value.isEmpty || !RegExp(r"^[a-zA-Z]").hasMatch(value)) {
//                     return 'Enter a valid Last Name!';
//                   }
//                   return null;
//                 }),
//             RoundedInputField(
//                 hintText: 'Email',
//                 onChanged: (value) {
//                   model.email = value;
//                 },
//                 icon: Icons.email_outlined,
//                 inputType: TextInputType.emailAddress,
//                 validator: (String value) {
//                   if (value.isEmpty ||
//                       !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                           .hasMatch(value)) {
//                     return 'Enter a valid Email!';
//                   }
//                   return null;
//                 }),
//             RoundedInputField(
//                 hintText: 'Mobile Number',
//                 onChanged: (value) {
//                   model.phoneNumber = value;
//                 },
//                 icon: Icons.phone,
//                 inputType: TextInputType.number,
//                 validator: (String value) {
//                   if (value.isEmpty ||
//                       value.length < 10 ||
//                       !RegExp(r"^[0-9]").hasMatch(value)) {
//                     return 'Enter a valid Mobile No!';
//                   }
//                   return null;
//                 }),
//             RoundPasswordField(
//               // isPassword: true,
//               onChanged: (value) {
//                 model.password = value;
//               },
//               inputType: TextInputType.text,
//               validator: (String value) {
//                 if (value.isEmpty ||
//                         value.length <
//                             8 /*||
//                     !RegExp(r'^(?=.*?[a-z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
//                         .hasMatch(value)*/
//                     ) {
//                   return 'Enter valid password';
//                 }
//               },
//             ),
//             Text(
//               'Are You Employee of the MetalMan?',
//               style: new TextStyle(
//                   fontSize: 15.0,
//                   fontWeight: FontWeight.bold,
//                   color: KPrimaryColor),
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.center,
//               children: [
//                 Radio(
//                   value: 'Y',
//                   groupValue: radioButtonVal,
//                   onChanged: (value) {
//                     setState(() {
//                       radioButtonVal = 'Y';
//                     });
//                   },
//                   activeColor: KPrimaryColor,
//                 ),
//                 Text("Yes"),
//                 Radio(
//                   value: 'N',
//                   groupValue: radioButtonVal,
//                   onChanged: (value) {
//                     setState(() {
//                       radioButtonVal = 'N';
//                     });
//                   },
//                   activeColor: KPrimaryColor,
//                 ),
//                 Text("No")
//               ],
//             ),
//             voidCheck(isEmployee: radioButtonVal),
//             isSubmit == true
//                 ? new Center(
//                     child: new CircularProgressIndicator(),
//                     // child: new Padding(
//                     //     padding: const EdgeInsets.all(5.0),
//                     //     child: new Center(
//                     //         child: new CircularProgressIndicator(
//                     //       valueColor: AlwaysStoppedAnimation(
//                     //           Theme.of(context).primaryColor),
//                     //     ))),
//                   )
//                 : RoundButton(
//                     text: "Signup".toUpperCase(),
//                     onpresed: () async {
//                       if (!(_formKey.currentState.validate())) {
//                         return;
//                       } else {
//                         await signup();
//                         SharedPreferences prefs =
//                             await SharedPreferences.getInstance();
//                         String token = prefs.getString("token");
//                         print(token);
//                         if (token != '') {
//                           // Navigator.push(
//                           //     context,
//                           //     MaterialPageRoute(
//                           //         builder: (context) => LoginScreen()));
//                         } else {
//                           CoolAlert.show(
//                               context: context,
//                               type: CoolAlertType.error,
//                               title: "User already registered",
//                               onConfirmBtnTap: () {
//                                 Navigator.pop(context, false);
//                                 // Navigator.push(
//                                 //     context,
//                                 //     MaterialPageRoute(
//                                 //         builder: (context) => LoginScreen()));
//                               });
//                         }
//                       }
//                     },
//                   ),
//             AlreadyHaveAccountCheck(
//               login: false,
//               pressed: () {
//                 // Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 //   return LoginScreen();
//                 // }));
//               },
//             ),
//             SizedBox(
//               height: 10,
//             )
//           ],
//         ),
//       ),
//     ));
//   }

//   voidCheck({String isEmployee}) {
//     if (isEmployee == 'Y') {
//       return RoundedInputField(
//         hintText: 'Enter MetalMan\'s Employee Id',
//         icon: Icons.contact_page,
//         inputType: TextInputType.number,
//       );
//     }
//     return Container();
//   }

//   // WillPopScope

//   Future signup() async {
//     setState(() {
//       isSubmit = false;
//     });
//     var url = Uri.parse('http://192.168.0.102:3000/signup');
//     http.Response response = await http.post(url,
//         headers: {'Content-Type': 'application/json;charset=UTF-8'},
//         body: jsonEncode({
//           "first_name": model.firstName,
//           "last_name": model.lastName,
//           "mobileno": model.phoneNumber,
//           "email": model.email,
//           "password": model.password
//         }));

//     print(response.statusCode);
//     print(response.body);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var parse = jsonDecode(response.body);
//     if (response.statusCode == 200) {
//       await prefs.setString("token", parse['token']);
//       setState(() {
//         isSubmit = true;
//       });
//     } else {
//       await prefs.setString("token", '');
//       setState(() {
//         isSubmit = true;
//       });
//     }
//   }
// }
