import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

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
  }) : super(key: key);

  final RoommateData roommateData;
  final DateTime selectedDate;
  final String hostelName;
  final String roomName;
  final String status;

  @override
  _AttendanceIconState createState() => _AttendanceIconState();
}

class _AttendanceIconState extends State<AttendanceIcon> {
  final presentIcon =
      const Icon(Icons.check_circle_outline, color: Colors.green);
  final absentIcon = const Icon(Icons.close_rounded, color: Colors.red);
  String? status;
  Icon currentIcon = const Icon(Icons.close_rounded, color: Colors.red);
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    status = widget.status;
    currentIcon = status == 'present' ? presentIcon : absentIcon;
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
        currentIcon = resp == 'present' ? presentIcon : absentIcon;
        isRunning = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
    return status == 'onLeave'
        ? const Text(
            'On Leave',
            style: TextStyle(
                backgroundColor: Colors.yellow, fontWeight: FontWeight.bold),
          )
        : AttendanceWid();
  }

  Widget AttendanceWid() {
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
