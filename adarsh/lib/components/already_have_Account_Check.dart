import 'package:adarsh/constant.dart';
import 'package:flutter/material.dart';

class AlreadyHaveAccountCheck extends StatelessWidget {
  final bool login;
  final Function pressed;

  const AlreadyHaveAccountCheck({
    Key key,
    this.login = true,
    this.pressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          login ? "Don't Have an Account ? " : "Already Have an Account ?",
          style: TextStyle(color: KPrimaryColor),
        ),
        GestureDetector(
          onTap: pressed,
          child: Text(
            login ? "Sign Up" : "Sign In",
            style: TextStyle(color: KPrimaryColor, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
