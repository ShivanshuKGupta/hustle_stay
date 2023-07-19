import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/tools.dart';

class SwapRoomRequest extends Request {
  String targetUserEmail;
  SwapRoomRequest({required this.targetUserEmail}) {
    super.type = "SwapRoomRequest";
  }

  @override
  Map<String, dynamic> encode() {
    final Map<String, dynamic> ans = super.encode();
    ans['targetUserEmail'] = targetUserEmail;
    return ans;
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    assert(data['targetUserEmail'] != null);
    // this request should definitely contain these property
    targetUserEmail = data['targetUserEmail'];
  }

  @override
  bool beforeUpdate() {
    targetUserEmail = targetUserEmail.trim();
    String? err = Validate.email(targetUserEmail, required: true);
    if (err != null) throw err;
    return super.beforeUpdate();
  }

  @override
  void onApprove() {
    // TODO: Sani
    // When request for swapping the room is accepted
    // this function will be called

    // Use [targetUserEmail] and [requestingUserEmail] to complete this function
    // and super.reason to get some more info
  }

  @override
  Widget widget(context) {
    // TODO: implement widget
    throw UnimplementedError();
  }
}
