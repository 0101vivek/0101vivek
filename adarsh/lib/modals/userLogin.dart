import 'package:flutter/material.dart';

class LoginModel {
  String email;
  String password;

  LoginModel({this.email, this.password});

  String getEmail() {
    return email;
  }

  String getPassword() {
    return password;
  }
}
