import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/room_list.dart';

import '../../../tools.dart';

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

  DateTime? selectedDate = DateTime.now();

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
          actions: [
            IconButton(
                onPressed: () async {
                  DateTime? date = await showDatePicker(
                      confirmText: "Are you sure?",
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2019),
                      lastDate: DateTime.now());
                  if (date != null && date != selectedDate) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined))
          ],
        ),
        body: numberOfRooms == 0
            ? Center(
                child: Text("No rooms exist yet!"),
              )
            : RoomList(
                hostelName: widget.hostelName, numberOfRooms: numberOfRooms));
  }
}
