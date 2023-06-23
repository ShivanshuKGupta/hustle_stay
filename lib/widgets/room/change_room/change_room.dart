import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/change_room/fetch_hostels.dart';

class ChangeRoomWidget extends StatefulWidget {
  ChangeRoomWidget(
      {super.key,
      required this.email,
      required this.roomName,
      required this.hostelName});
  String email;
  String roomName;
  String hostelName;
  @override
  State<ChangeRoomWidget> createState() => _ChangeRoomWidgetState();
}

class _ChangeRoomWidgetState extends State<ChangeRoomWidget> {
  @override
  Widget build(BuildContext context) {
    return FetchHostelNames(
        email: widget.email,
        roomName: widget.roomName,
        hostelName: widget.hostelName);
  }
}
