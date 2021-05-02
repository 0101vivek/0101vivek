import 'package:flutter/material.dart';

class RoomBookModel {
  String roomId;
  String userId;
  String startingDate;
  String endingDate;
  String totalAmount;

  RoomBookModel(
      {this.roomId,
      this.userId,
      this.startingDate,
      this.endingDate,
      this.totalAmount});
}
