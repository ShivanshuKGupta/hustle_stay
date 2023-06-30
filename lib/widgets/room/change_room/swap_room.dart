import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';

import '../../../screens/hostel/rooms/rooms_screen.dart';
import '../../../tools.dart';

class SwapRoom extends StatefulWidget {
  SwapRoom(
      {super.key,
      required this.destRoomName,
      required this.isSwap,
      required this.destHostelName,
      required this.email,
      required this.roomName,
      required this.hostelName,
      required this.destRoommateEmail});
  String destHostelName;
  String destRoomName;
  String email;
  String roomName;
  String hostelName;
  bool isSwap;
  String destRoommateEmail;

  @override
  State<SwapRoom> createState() => _SwapRoomState();
}

class _SwapRoomState extends State<SwapRoom> {
  void _submitForm() async {
    bool resp = await swapRoom(
        widget.email,
        widget.hostelName,
        widget.roomName,
        widget.destRoommateEmail,
        widget.destHostelName,
        widget.destRoomName,
        context);
    if (!resp) {
      setState(() {
        isRunning = false;
      });
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => RoomsScreen(hostelName: widget.hostelName),
    ));
  }

  bool isRunning = false;
  @override
  Widget build(BuildContext context) {
    return isRunning
        ? Center(child: circularProgressIndicator())
        : Center(
            child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    isRunning = true;
                  });
                  _submitForm();
                },
                icon: Icon(Icons.update_rounded),
                label: Text('Swap Record')),
          );
  }
}
