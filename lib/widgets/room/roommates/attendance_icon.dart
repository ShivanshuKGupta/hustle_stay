import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/hostels.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';
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
  final presentIcon = const Icon(
    Icons.check_circle_outline,
  );
  final absentIcon = const Icon(
    Icons.cancel_outlined,
  );
  String? status;
  Icon currentIcon = const Icon(Icons.cancel_outlined);
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
        status = resp;
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

  bool isChanged = false;

  @override
  void didUpdateWidget(covariant AttendanceIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    {
      status = widget.status;
    }
    _getAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return status == 'onLeave' || status == 'onInternship'
        ? Padding(
            padding: const EdgeInsets.all(2.0),
            child: ElevatedButton(
              onPressed: null,
              onLongPress: widget.roommateData.leaveEndDate == null
                  ? () {}
                  : () async {
                      final response = await askUser(
                        context,
                        'Are you sure to end Leave ?',
                        yes: true,
                        no: true,
                      );
                      if (response == "yes") {
                        bool resp = await setLeave(widget.roommateData.email,
                            widget.hostelName, true, true,
                            leaveEndDate: DateTime.now());
                        if (resp) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => RoomsScreen(
                                      hostelName: widget.hostelName)));
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.tileColor!.value,
                  side: const BorderSide(
                      style: BorderStyle.solid, color: Colors.black)),
              child: Text(
                "${status![0].toUpperCase()}${status![1]} ${status!.substring(2)}",
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
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
              String resp = await setAttendanceData(
                widget.roommateData.email,
                widget.hostelName,
                widget.roomName,
                widget.selectedDate,
                status!,
              );
              if (resp != 'false' && mounted) {
                setState(() {
                  status = resp;
                  widget.tileColor!.value = colorPickerAttendance(resp);
                  currentIcon = resp == 'present' || resp == 'presentLate'
                      ? presentIcon
                      : absentIcon;
                  isRunning = false;
                });
              }
              // final notRef = await FirebaseFirestore.instance
              //     .collection('userTokens')
              //     .doc(widget.roommateData.email)
              //     .collection('Tokens')
              //     .get();
              // if (resp) {
              //   final messaging = FirebaseMessaging.instance;
              //   for (final x in notRef.docs) {
              //     await messaging.sendMessage(
              //       to: x.data()['token'],
              //       collapseKey: 'update',
              //       data: RemoteMessage(data: {
              //         'title':'Marked'
              //       })
              //     );
              //   }
              // }
            },
            icon: currentIcon,
          );
  }
}
