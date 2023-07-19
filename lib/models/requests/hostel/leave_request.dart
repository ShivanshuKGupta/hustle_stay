import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class LeaveRequest extends Request {
  DateTime dateTime;
  LeaveRequest({required this.dateTime}) {
    super.type = "Leave";
  }

  @override
  Map<String, dynamic> encode() {
    final Map<String, dynamic> ans = super.encode();
    ans['dateTime'] = dateTime;
    return ans;
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    assert(data['dateTime'] != null);
    // this request should definitely contain these property
    dateTime = data['dateTime'];
  }

  @override
  bool beforeUpdate() {
    // TODO: Sani
    // using the [dateTime] object you can do some checks here
    // return false if those check are not meant or throw an error with some
    // description

    // If you return false request won't be posted
    return super.beforeUpdate();
  }

  @override
  void onApprove() {
    // TODO: Sani

    // When request for leaving the hostel on [dateTime] is accepted
    // this function will be called

    // Use [dateTime] and [requestingUserEmail] to complete this function
    // and super.reason to get some more info
  }

  @override
  Widget widget(context) {
    // TODO: implement widget
    throw UnimplementedError();
  }
}
