import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class VanRequest extends Request {
  DateTime? dateTime;

  VanRequest() {
    super.type = "OtherTravelRequest";
  }

  @override
  Map<String, dynamic> encode() {
    return super.encode()
      ..addAll({
        'dateTime': dateTime!.millisecondsSinceEpoch,
      });
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    dateTime = DateTime.fromMillisecondsSinceEpoch(data['dateTime']);
  }

  @override
  bool onUpdate() {
    assert(dateTime != null);
    assert(reason.isNotEmpty);
    return super.onUpdate();
  }

  @override
  void onApprove() {
    // TODO: send notifications and email etc.
  }

  @override
  Widget widget() {
    // TODO: implement widget
    throw UnimplementedError();
  }
}
