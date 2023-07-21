import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class ChangeRoomRequest extends Request {
  String targetRoomName;
  String targetHostel;
  ChangeRoomRequest({
    required super.requestingUserEmail,
    this.targetRoomName = '',
    this.targetHostel = '',
  }) : super(
          type: 'Change_Room',
          uiElement: {
            'color': Colors.blueAccent,
            'icon': Icons.transfer_within_a_station_rounded,
          },
        );

  @override
  Map<String, dynamic> encode() {
    return super.encode()
      ..addAll({
        'targetRoomName': targetRoomName,
        'targetHostel': targetHostel,
      });
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    targetRoomName = data['targetRoomName']!;
    targetHostel = data['targetHostel']!;
  }

  @override
  bool beforeUpdate() {
    targetRoomName = targetRoomName.trim();
    targetHostel = targetHostel.trim();
    assert(targetRoomName.isNotEmpty);
    assert(targetHostel.isNotEmpty);
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
