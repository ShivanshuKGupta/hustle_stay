import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/widgets/room/room_list.dart';
import 'package:hustle_stay/widgets/room/roommates/pie_chart_attendance.dart';

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
  bool allPresent = false;
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
          if (!isUpdating)
            IconButton(
                onPressed: () {
                  setState(() {
                    showStats = !showStats;
                  });
                },
                icon: showStats
                    ? const Icon(Icons.list)
                    : const Icon(Icons.bar_chart_rounded)),
          if (!isUpdating)
            IconButton(
              onPressed: () async {
                final response = await askUser(
                  context,
                  'Are you sure to mark everyone ${allPresent ? 'absent' : 'present'} ?',
                  yes: true,
                  no: true,
                );
                if (response == 'yes') {
                  setState(() {
                    isUpdating = true;
                  });
                  final resp = await markAllAttendance(widget.hostelName,
                      allPresent ? false : true, selectedDate.value);
                  if (resp && mounted) {
                    setState(() {
                      allPresent = !allPresent;
                      isUpdating = false;
                    });
                  }
                }
              },
              icon: Icon(allPresent ? Icons.cancel : Icons.check_circle),
            ),
          if (!isUpdating)
            IconButton(
                onPressed: () {
                  setState(() {
                    filterRecord = !filterRecord;
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
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                              hintText: "Enter email to filter"),
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
                    Expanded(
                        child: FilteredRecords(email: emailController.text)),
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
                    : RoomList(
                        selectedDate: selectedDate,
                        hostelName: widget.hostelName,
                        numberOfRooms: numberOfRooms),
              );
  }
}
