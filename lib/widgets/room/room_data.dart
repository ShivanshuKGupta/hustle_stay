import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/attendance.dart';
import '../../models/hostel/rooms/room.dart';
import '../../screens/hostel/rooms/roommate_form.dart';
import '../../tools.dart';
import 'roommates/roommate_list.dart';

class RoomDataWidget extends StatefulWidget {
  RoomDataWidget(
      {super.key,
      required this.roomData,
      required this.hostelName,
      required this.selectedDate});
  Room roomData;
  String hostelName;
  ValueNotifier<DateTime> selectedDate;
  @override
  State<RoomDataWidget> createState() => _RoomDataWidgetState();
}

class _RoomDataWidgetState extends State<RoomDataWidget> {
  bool isOpen = false;
  bool isRunning = false;
  bool allPresent = false;
  bool isDisabled = false;
  // Color tileColor = Colors.white;
  @override
  void didUpdateWidget(covariant RoomDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // tileColor = findColor();
  }

  @override
  void initState() {
    super.initState();
    // tileColor = findColor();
  }

  // Color findColor() {
  //   if (widget.roomData.statusFraction != null) {
  //     int red = (255 * (1 - widget.roomData.statusFraction!)).toInt();
  //     int green = (255 * widget.roomData.statusFraction!).toInt();
  //     return Color.fromRGBO(red, green, 10, 1);
  //   }
  //   return Colors.grey;
  // }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    final Brightness brightness = Theme.of(context).brightness;
    int random = Random().nextInt(colorList.length);
    final Color cardColor = colorList[random];

    return Container(
      padding: EdgeInsets.all(widthScreen * 0.01),
      child: Card(
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: brightness == Brightness.light
                    ? Colors.black
                    : Colors.white),
            borderRadius: BorderRadius.circular(16.0),
            color: cardColor.withOpacity(0.2),
            boxShadow: brightness == Brightness.light
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.roomData.roomName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capacity: ${widget.roomData.capacity}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isDisabled && widget.roomData.numberOfRoommates > 0)
                      IconButton(
                        onPressed: isDisabled
                            ? null
                            : () async {
                                final response = await askUser(
                                    context, 'Choose your operation ',
                                    custom: ['Present', 'Absent', 'Cancel']);
                                if (response == 'Present' ||
                                    response == 'Absent') {
                                  setState(() {
                                    isDisabled = true;
                                  });
                                  final resp = await markAllRoommateAttendance(
                                      widget.hostelName,
                                      widget.roomData.roomName,
                                      response != 'Present' ? false : true,
                                      widget.selectedDate.value);
                                  if (resp && mounted) {
                                    setState(() {
                                      isDisabled = false;
                                    });
                                  } else if (!resp) {
                                    showMsg(context,
                                        'Unable to perform. Try again');
                                  }
                                }
                              },
                        icon: Icon(Icons.checklist_rounded),
                      ),
                    if (widget.roomData.capacity >
                        widget.roomData.numberOfRoommates)
                      IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (_) => RoommateForm(
                                        capacity: widget.roomData.capacity,
                                        hostelName: widget.hostelName,
                                        roomName: widget.roomData.roomName,
                                        numRoommates:
                                            widget.roomData.numberOfRoommates,
                                      )));
                        },
                        icon: const Icon(Icons.add),
                      ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    icon: !isOpen
                        ? const Icon(Icons.arrow_drop_down_outlined)
                        : const Icon(Icons.arrow_drop_up_outlined)),
                if (isOpen)
                  widget.roomData.numberOfRoommates == 0
                      ? const Center(
                          child: Text(
                          "No roommates added yet",
                          style: TextStyle(color: Colors.black),
                        ))
                      : RoommateWidget(
                          roomData: widget.roomData,
                          selectedDate: widget.selectedDate,
                          hostelName: widget.hostelName,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
