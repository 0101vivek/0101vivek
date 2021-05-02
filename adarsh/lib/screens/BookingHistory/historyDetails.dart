import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HistoryDetails {
  final List<Details> result;
  final String msg;

  HistoryDetails({this.result, this.msg});

  factory HistoryDetails.fromJson(Map<String, dynamic> json) {
    return new HistoryDetails(
        result: json['result'], msg: json['msg'] as String);
  }
}

class Details {
  final String userId;
  final String roomId;
  final String roomBookingDay;
  final String roomEndingDay;
  final int totalAmount;
  final int roomNumber;
  final String description;
  final String roomType;

  Details(
      {this.userId,
      this.roomId,
      this.roomType,
      this.roomNumber,
      this.roomBookingDay,
      this.roomEndingDay,
      this.totalAmount,
      this.description});

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
        userId: json['userId'] as String,
        roomId: json['roomId'] as String,
        roomBookingDay: json['startDate'] as String,
        roomEndingDay: json['endDate'] as String,
        description: json['description'] as String,
        totalAmount: json['Amount'] as int,
        roomNumber: json['roomNumber'] as int,
        roomType: json['roomType'] as String);
  }
}
