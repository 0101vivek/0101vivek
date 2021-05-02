import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Room {
  final List<RoomDetails> result;
  final String msg;

  Room({this.result, this.msg});

  factory Room.fromJson(Map<String, dynamic> json) {
    return new Room(result: json['result'], msg: json['msg'] as String);
  }
}

class RoomDetails {
  final String id;
  final int roomNumber;
  final String description;
  final int charges;
  final String image;

  RoomDetails(
      {this.id, this.roomNumber, this.description, this.charges, this.image});

  factory RoomDetails.fromJson(Map<String, dynamic> json) {
    return RoomDetails(
      id: json['_id'] as String,
      roomNumber: json['roomNumber'] as int,
      description: json['description'] as String,
      charges: json['charges'] as int,
      image: json['image'] as String,
    );
  }
}
