import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../screens/roommate_form.dart';
import '../../tools.dart';
import 'room_data.dart';
import 'roommates/roommate_list.dart';

class RoomList extends StatefulWidget {
  RoomList({super.key, required this.hostelName, required this.numberOfRooms});
  String hostelName;
  int numberOfRooms;

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder(
        future: fetchRooms(widget.hostelName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: circularProgressIndicator(
                height: null,
                width: null,
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Rooms added yet!'),
            );
          }
          print(snapshot.data);
          print(snapshot.data![0]);
          return ListView.builder(
            itemCount: widget.numberOfRooms,
            itemBuilder: (context, index) {
              final roomData = snapshot.data![index];
              return RoomDataWidget(
                hostelName: widget.hostelName,
                roomData: roomData,
              );
            },
          );
        },
      ),
    );
  }
}
