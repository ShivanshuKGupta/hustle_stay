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
  final absentIcon = const Icon(Icons.close_rounded, color: Colors.black);
  String? status;
  Icon currentIcon = const Icon(Icons.close_rounded, color: Colors.black);
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.tileColor!.value,
                  side: const BorderSide(
                      style: BorderStyle.solid, color: Colors.black)),
              child: Text(status!),
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
