import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class ChangeRoomRequest extends Request {
  String targetRoomName;
  ChangeRoomRequest({this.targetRoomName = ''}) {
    super.type = "ChangeRoomRequest";
  }

  @override
  Map<String, dynamic> encode() {
    return super.encode()..addAll({'targetRoomName': targetRoomName});
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    assert(data['targetRoomName'] != null);
    // this request should definitely contain above properties
    targetRoomName = data['targetRoomName'];
  }

  @override
  bool beforeUpdate() {
    targetRoomName = targetRoomName.trim();
    assert(targetRoomName.isNotEmpty);
    return super.beforeUpdate();
  }

  @override
  void onApprove() {
    // TODO: Sani

    // When request for changing the room to [targetRoomName] is accepted
    // this function will be called

    // Use [targetRoomName] and [requestingUserEmail] to complete this function
    // and super.reason to get some more info
  }

  @override
  Widget widget(context) {
    // TODO: implement widget
    throw UnimplementedError();
  }
}
