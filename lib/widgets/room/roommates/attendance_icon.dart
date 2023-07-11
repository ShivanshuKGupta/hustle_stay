import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/hostels.dart';
import 'package:hustle_stay/tools.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance.dart';
import '../../../models/hostel/rooms/room.dart';

class AttendanceIcon extends StatefulWidget {
  const AttendanceIcon({
    Key? key,
    required this.roommateData,
    required this.selectedDate,
    required this.roomName,
    required this.hostelName,
    required this.status,
    this.tileColor,
  }) : super(key: key);

  final RoommateData roommateData;
  final DateTime selectedDate;
  final String hostelName;
  final String roomName;
  final String status;
  final ValueNotifier<Color>? tileColor;

  @override
  _AttendanceIconState createState() => _AttendanceIconState();
}

class _AttendanceIconState extends State<AttendanceIcon> {
  final presentIcon =
      const Icon(Icons.check_circle_outline, color: Colors.black);
  final absentIcon = const Icon(Icons.cancel_outlined, color: Colors.black);
  String? status;
  Icon currentIcon = const Icon(Icons.cancel_outlined, color: Colors.black);
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    status = widget.status;
    currentIcon = status == 'present' || status == 'presentLate'
        ? presentIcon
        : absentIcon;
  }

  Future<void> _getAttendanceData() async {
    String resp = await getAttendanceData(
      widget.roommateData,
      widget.hostelName,
      widget.roomName,
      widget.selectedDate,
    );
    if (mounted) {
      setState(() {
        widget.tileColor!.value = colorPickerAttendance(resp);
        currentIcon = resp == 'present' || resp == 'presentLate'
            ? presentIcon
            : absentIcon;
        isRunning = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AttendanceIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    status = widget.status;
    _getAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return status == 'onLeave' || status == 'onInternship'
        ? Padding(
            padding: const EdgeInsets.all(2.0),
            child: ElevatedButton(
              onPressed: null,
              onLongPress: () async {
                final response = await askUser(
                  context,
                  'Are you sure to end Leave ?',
                  yes: true,
                  no: true,
                );
                if (response == "yes") {
                  bool resp = await setLeave(widget.roommateData.email,
                      widget.hostelName, widget.roomName, true, true,
                      selectedDate: DateTime.now());
                  if (resp) {
                    setState(() {
                      status = 'absent';
                      widget.tileColor!.value = Colors.redAccent;
                      currentIcon = absentIcon;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.tileColor!.value,
                  side: const BorderSide(
                      style: BorderStyle.solid, color: Colors.black)),
              child: Text(
                "${status![0].toUpperCase()}${status![1]} ${status!.substring(2)}",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          )
        : attendanceWid();
  }

  Widget attendanceWid() {
    return isRunning
        ? circularProgressIndicator()
        : IconButton(
            onPressed: () async {
              setState(() {
                isRunning = true;
              });
              await setAttendanceData(
                widget.roommateData.email,
                widget.hostelName,
                widget.roomName,
                widget.selectedDate,
                currentIcon == presentIcon,
              );
              await _getAttendanceData();
            },
            icon: currentIcon,
          );
  }
}
