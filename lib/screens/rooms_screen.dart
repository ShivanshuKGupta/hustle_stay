import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/room_list.dart';

import '../tools.dart';

class RoomsScreen extends StatefulWidget {
  RoomsScreen({super.key, required this.hostelName});
  String hostelName;
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final store = FirebaseFirestore.instance;
  int numberOfRooms = 0;
  void getnumRooms() async {
    print(widget.hostelName);
    await store.collection('hostels').doc(widget.hostelName).get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          numberOfRooms = data!['numberOfRooms'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getnumRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: shaderText(context, title: "Rooms"),
        ),
        body: RoomList(
            hostelName: widget.hostelName, numberOfRooms: numberOfRooms));
  }
}
