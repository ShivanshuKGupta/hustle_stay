import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/hostel/rooms/room.dart';
import '../../tools.dart';
import 'room_data.dart';

class RoomList extends StatefulWidget {
  const RoomList(
      {super.key,
      required this.hostelName,
      required this.numberOfRooms,
      required this.selectedDate});
  final String hostelName;
  final int numberOfRooms;
  final DateTime selectedDate;

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
        return RoomListWidget(
            snapshot.data!, widget.hostelName, widget.numberOfRooms);
      },
    );
  }

  Widget RoomListWidget(List<Room> room, String hostelName, int numberOfRooms) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        itemCount: numberOfRooms,
        itemBuilder: (context, index) {
          final roomData = room[index];
          return RoomDataWidget(
            hostelName: hostelName,
            roomData: roomData,
            selectedDate: widget.selectedDate,
          );
        },
      ),
    );
  }
}
