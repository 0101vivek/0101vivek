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
  final String orderId;
  final int totalAmount;
  final int roomNumber;
  final String image;
  final String roomType;
  final String status;
  final String bookingStatus;
  final String payment;
  final String paymentStatus;
  final String paytmOrderId;

  Details(
      {this.userId,
      this.image,
      this.orderId,
      this.payment,
      this.roomId,
      this.paymentStatus,
      this.paytmOrderId,
      this.roomType,
      this.status,
      this.roomNumber,
      this.roomBookingDay,
      this.roomEndingDay,
      this.totalAmount,
      this.bookingStatus});

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
        userId: json['userId'] as String,
        image: json['image'] as String,
        roomId: json['roomid'] as String,
        roomBookingDay: json['startDate'] as String,
        roomEndingDay: json['endDate'] as String,
        totalAmount: json['Amount'] as int,
        roomNumber: json['roomNumber'] as int,
        orderId: json['_id'] as String,
        status: json['status'] as String,
        payment: json['paymentStatus'] as String,
        bookingStatus: json['BookingStatus'] as String,
        paymentStatus: json['paymentStatus'] as String,
        paytmOrderId: json['paymentOrderId'] as String,
        roomType: json['roomType'] as String);
  }
}
