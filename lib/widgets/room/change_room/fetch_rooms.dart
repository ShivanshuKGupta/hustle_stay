import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../../tools.dart';

class FetchRooms extends StatefulWidget {
  FetchRooms(
      {super.key,
      required this.destHostelName,
      required this.email,
      required this.roomName,
      required this.hostelName});
  String destHostelName;
  String email;
  String roomName;
  String hostelName;
  @override
  State<FetchRooms> createState() => _FetchRoomsState();
}

class _FetchRoomsState extends State<FetchRooms> {
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchRoomNames(widget.destHostelName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: circularProgressIndicator(
              height: null,
              width: null,
            ),
          );
        }
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Text(
                    'Choose new Room',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  DropdownButton(
                      items: snapshot.data,
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
                          label: Text('Update Record')),
                    ),
          ],
        );
      },
    );
  }
}
