import 'package:cloud_firestore/cloud_firestore.dart';
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
          if (!snapshot.hasData) {
            return FutureBuilder(
              future: fetchRooms(widget.hostelName, src: Source.cache),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasData && snapshot.error != null) {
                  return Center(
                    child: circularProgressIndicator(
                      height: null,
                      width: null,
                    ),
                  );
                }
                return RoomListWidget(
                    snapshot.data!, widget.hostelName, widget.numberOfRooms);
              },
            );
          }
          print(snapshot.data);
          print(snapshot.data![0]);
          return RoomListWidget(
              snapshot.data!, widget.hostelName, widget.numberOfRooms);
        },
      ),
    );
  }
}

Widget RoomListWidget(List<Room> room, String hostelName, int numberOfRooms) {
  return ListView.builder(
    itemCount: numberOfRooms,
    itemBuilder: (context, index) {
      final roomData = room[index];
      return RoomDataWidget(
        hostelName: hostelName,
        roomData: roomData,
      );
    },
  );
}
