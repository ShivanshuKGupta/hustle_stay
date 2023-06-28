import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';

import '../../../tools.dart';

class SwapRoom extends StatefulWidget {
  SwapRoom(
      {super.key,
      required this.destRoomName,
      required this.isSwap,
      required this.destHostelName,
      required this.email,
      required this.roomName,
      required this.hostelName});
  String destHostelName;
  String destRoomName;
  String email;
  String roomName;
  String hostelName;
  bool isSwap;

  @override
  State<SwapRoom> createState() => _SwapRoomState();
}

class _SwapRoomState extends State<SwapRoom> {
  void _submitForm() async {
    bool resp = await swapRoom(
        widget.email,
        widget.hostelName,
        widget.roomName,
        destRoommateEmail!,
        widget.destHostelName,
        widget.destRoomName,
        context);
    if (!resp) {
      setState(() {
        isRunning = false;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  bool isRunning = false;
  String? destRoommateEmail;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchRoommateNames(widget.destHostelName, widget.destRoomName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: fetchRoommateNames(
                widget.destHostelName, widget.destRoomName,
                src: Source.cache),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.error != null) {
                return Center(
                  child: circularProgressIndicator(
                    height: null,
                    width: null,
                  ),
                );
              }
              return NamesDropDown(snapshot.data!);
            },
          );
        }
        return NamesDropDown(snapshot.data!);
      },
    );
  }

  Widget NamesDropDown(List<DropdownMenuItem> list) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Text(
                'Roommate to swap',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                width: 5,
              ),
              DropdownButton(
                  items: list,
                  value: destRoommateEmail,
                  onChanged: (value) {
                    setState(() {
                      destRoommateEmail = value;
                    });
                  }),
            ],
          ),
        ),
        if (destRoommateEmail != null && destRoommateEmail != "")
          isRunning
              ? CircularProgressIndicator()
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
                )
      ],
    );
  }
}
