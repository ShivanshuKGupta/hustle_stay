import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/room_list.dart';

import '../../../tools.dart';
import '../../../widgets/room/filtered_attendance.dart';
import 'package:flutter/foundation.dart';

class RoomsScreen extends StatefulWidget {
  RoomsScreen({super.key, required this.hostelName});
  String hostelName;
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final store = FirebaseFirestore.instance;
  String? email;
  String emailVal = "";
  bool filterRecord = false;
  int numberOfRooms = 0;
  void getnumRooms() async {
    await store.collection('hostels').doc(widget.hostelName).get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          numberOfRooms = data!['numberOfRooms'];
        });
      }
    });
  }

  bool isOpen = false;

  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getnumRooms();
  }

  @override
  void didUpdateWidget(covariant RoomsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Rooms"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  filterRecord = !filterRecord;
                });
              },
              icon: filterRecord
                  ? Icon(Icons.person_remove)
                  : Icon(Icons.filter_alt_rounded)),
          IconButton(
              onPressed: () async {
                DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2019),
                    lastDate: DateTime.now());
                if (date != null && date != selectedDate) {
                  selectedDate.value = date;
                }
              },
              icon: const Icon(Icons.calendar_month_outlined))
        ],
      ),
      body: filterRecord
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration:
                            InputDecoration(hintText: "Enter email to filter"),
                        controller: emailController,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isOpen = true;
                          });
                        },
                        icon: const Icon(Icons.search_sharp)),
                  ],
                ),
                if (isOpen)
                  Expanded(child: FilteredRecords(email: emailController.text)),
              ],
            )
          : Container(
              child: numberOfRooms == 0
                  ? Center(
                      child: circularProgressIndicator(
                        height: null,
                        width: null,
                      ),
                    )
                  : Container(
                      child: RoomList(
                          selectedDate: selectedDate,
                          hostelName: widget.hostelName,
                          numberOfRooms: numberOfRooms),
                    ),
            ),
    );
  }
}