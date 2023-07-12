import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/hostel/rooms/room.dart';
import '../../tools.dart';
import 'room_data.dart';
import 'package:connectivity/connectivity.dart';

class RoomList extends StatefulWidget {
  const RoomList(
      {super.key,
      required this.hostelName,
      required this.numberOfRooms,
      required this.selectedDate});
  final String hostelName;
  final int numberOfRooms;
  final ValueNotifier<DateTime> selectedDate;

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final connResult = await Connectivity().checkConnectivity();

    setState(() {
      isConnected = !(ConnectivityResult.none == connResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          fetchRooms(widget.hostelName, src: isConnected ? null : Source.cache),
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
            child: ErrorWidget(const Text(
                'Unable to fetch data. The data could be empty or you might not have the permission to access the data. Contact the developers for more info.')),
          );
        }
        return roomListWidget(
            snapshot.data!, widget.hostelName, widget.numberOfRooms);
      },
    );
  }

  Widget roomListWidget(List<Room> room, String hostelName, int numberOfRooms) {
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
