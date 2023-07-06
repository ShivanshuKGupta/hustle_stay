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
    required this.isPresent,
  }) : super(key: key);

  final RoommateData roommateData;
  final DateTime selectedDate;
  final String hostelName;
  final String roomName;
  final bool isPresent;

  @override
  _AttendanceIconState createState() => _AttendanceIconState();
}

class _AttendanceIconState extends State<AttendanceIcon> {
  final presentIcon = Icon(Icons.check_circle_outline, color: Colors.green);
  final absentIcon = Icon(Icons.close_rounded, color: Colors.red);
  bool? isPresent;
  Icon currentIcon = Icon(Icons.close_rounded, color: Colors.red);
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    isPresent = widget.isPresent;
    currentIcon = isPresent! ? presentIcon : absentIcon;
  }

  Future<void> _getAttendanceData() async {
    bool resp = await getAttendanceData(
      widget.roommateData,
      widget.hostelName,
      widget.roomName,
      widget.selectedDate,
    );
    if (mounted) {
      setState(() {
        currentIcon = resp ? presentIcon : absentIcon;
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
    _getAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return widget.roommateData.onLeave != null &&
            widget.roommateData.onLeave! &&
            widget.roommateData.leaveStartDate != null &&
            (widget.roommateData.leaveStartDate!
                .isBefore(widget.selectedDate)) &&
            widget.roommateData.leaveEndDate != null &&
            (widget.roommateData.leaveEndDate!.isAfter(widget.selectedDate))
        ? Text(
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
