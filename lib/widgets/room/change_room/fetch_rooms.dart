import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';
import 'package:hustle_stay/widgets/room/change_room/fetch_roommates.dart';

import '../../../models/hostel/rooms/room.dart';
import '../../../tools.dart';
import 'swap_room.dart';

class FetchRooms extends StatefulWidget {
  FetchRooms(
      {super.key,
      required this.isSwap,
      required this.destHostelName,
      required this.email,
      required this.roomName,
      required this.hostelName});
  String destHostelName;
  String email;
  String roomName;
  String hostelName;
  bool isSwap;
  @override
  State<FetchRooms> createState() => _FetchRoomsState();
}

class _FetchRoomsState extends State<FetchRooms> {
  @override
  void didUpdateWidget(covariant FetchRooms oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      destRoomName = null;
    });
  }

  bool isRunning = false;
  String? destRoomName;
  void _submitForm() async {
    bool resp = await changeRoom(widget.email, widget.hostelName,
        widget.roomName, widget.destHostelName, destRoomName!, context);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchRoomNames(widget.destHostelName,
          roomname: widget.destHostelName == widget.hostelName
              ? widget.roomName
              : null),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: circularProgressIndicator(
              height: 2,
              width: 2,
            ),
          );
        }
        return RoomDropdownWithSubmit(snapshot.data!);
      },
    );
  }

  Widget RoomDropdownWithSubmit(List<DropdownMenuItem> list) {
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              Text(
                'Select new Room',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                width: 5,
              ),
              DropdownButton(
                  items: list,
                  value: destRoomName,
                  onChanged: (value) {
                    setState(() {
                      destRoomName = value;
                    });
                  }),
            ],
          ),
        ),
        if (destRoomName != null && destRoomName != "")
          !widget.isSwap
              ? isRunning
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
                          label: Text('Update Record')),
                    )
              : FetchRoommates(
                  destRoomName: destRoomName!,
                  isSwap: widget.isSwap,
                  destHostelName: widget.destHostelName,
                  email: widget.email,
                  roomName: widget.roomName,
                  hostelName: widget.hostelName),
      ],
    );
  }
}
