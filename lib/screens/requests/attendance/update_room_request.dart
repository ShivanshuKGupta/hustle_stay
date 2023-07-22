import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/requests/room.dart/update_room.dart';

class UpdateRoom extends StatelessWidget {
  const UpdateRoom(
      {super.key, this.isSwap = false, this.hostelName, this.roomName});
  final bool isSwap;
  final String? hostelName;
  final String? roomName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSwap ? 'Swap Room Request' : 'Change Room Request'),
      ),
      body: UpdateRoomWidget(
        isSwap: isSwap,
        hostelName: hostelName,
        roomName: roomName,
      ),
    );
  }
}
