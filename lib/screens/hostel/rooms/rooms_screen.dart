import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/widgets/room/room_list.dart';
import 'package:hustle_stay/widgets/room/roommates/chart_attendance.dart';

import '../../../tools.dart';
import '../../../widgets/room/filtered_attendance.dart';

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
  bool isUpdating = false;
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

  bool showStats = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Rooms"),
        actions: [
          if (!isUpdating)
            IconButton(
                onPressed: () {
                  setState(() {
                    showStats = !showStats;
                    filterRecord = false;
                  });
                },
                icon: showStats
                    ? const Icon(Icons.list)
                    : const Icon(Icons.bar_chart_rounded)),
          // if (!isUpdating)
          //   IconButton(
          //     onPressed: () async {
          //       final response = await askUser(
          //           context, 'Choose your operation.',
          //           description:
          //               'All the students will be marked based on your operation',
          //           custom: ['Present', 'Absent', 'Cancel']);
          //       if (response == 'Absent' || response == 'Present') {
          //         setState(() {
          //           isUpdating = true;
          //         });
          //         final resp = await markAllAttendance(widget.hostelName,
          //             response != 'Present' ? false : true, selectedDate.value);
          //         if (resp && mounted) {
          //           setState(() {
          //             isUpdating = false;
          //           });
          //         }
          //       }
          //     },
          //     icon: const Icon(Icons.checklist_rtl_outlined),
          //   ),
          if (!isUpdating)
            IconButton(
                onPressed: () {
                  setState(() {
                    filterRecord = !filterRecord;
                    showStats = false;
                  });
                },
                icon: filterRecord
                    ? const Icon(Icons.person_remove)
                    : const Icon(Icons.filter_alt_rounded)),
          if (!isUpdating)
            IconButton(
                onPressed: () async {
                  DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2019),
                      lastDate: DateTime.now());
                  if (date != null && date != selectedDate.value) {
                    selectedDate.value = date;
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined))
        ],
      ),
      body: isUpdating
          ? Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimateIcon(
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.refresh,
                    ),
                    const Text('Updation in progress!')
                  ],
                ),
              ),
            )
          : bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return showStats
        ? AttendancePieChart(
            hostelName: widget.hostelName,
            selectedDate: selectedDate,
          )
        : filterRecord
            ? FilteredRecords(
                hostelName: widget.hostelName,
                selectedDate: selectedDate,
              )
            : Container(
                child: numberOfRooms == 0
                    ? Center(
                        child: circularProgressIndicator(
                          height: null,
                          width: null,
                        ),
                      )
                    : RoomList(
                        selectedDate: selectedDate,
                        hostelName: widget.hostelName,
                        numberOfRooms: numberOfRooms),
              );
  }
}
