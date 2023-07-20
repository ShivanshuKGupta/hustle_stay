import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class ChangeRoomRequest extends Request {
  String targetRoomName;
  String targetHostel;
  ChangeRoomRequest({this.targetRoomName = '', this.targetHostel = ''}) {
    super.type = "Change Room";
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
  void onApprove() async {
    // TODO: Sani

    // final user = await fetchUserData(requestingUserEmail, readonly: true);
    // await changeRoom(requestingUserEmail, user.readonly.hostelName!, user.readonly.roomName!,
    // targetHostel, targetRoomName, );
    // requestingUserEmail;
    // targetHostel;
    // targetRoomName;
  }

  @override
  Widget widget(context) {
    // TODO: implement widget
    throw UnimplementedError();
  }
}
