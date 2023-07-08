import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';
import 'package:hustle_stay/widgets/room/roommates/attendance_icon.dart';

import '../../../screens/hostel/rooms/complete_details_screen.dart';
import '../../../tools.dart';

class RoommateDataWidget extends StatefulWidget {
  const RoommateDataWidget(
      {super.key,
      required this.roommateData,
      required this.selectedDate,
      required this.roomName,
      required this.hostelName,
      this.isNeeded,
      this.status});
  final RoommateData roommateData;
  final DateTime selectedDate;
  final String hostelName;
  final String roomName;
  final bool? isNeeded;
  final String? status;

  @override
  State<RoommateDataWidget> createState() => _RoommateDataWidgetState();
}

class _RoommateDataWidgetState extends State<RoommateDataWidget> {
  @override
  void didUpdateWidget(covariant RoommateDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getAttendanceData();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isNeeded != null && widget.isNeeded == true) {
      _getAttendanceData();
    } else {
      status = widget.status;
    }
  }

  bool isOnScreen = true;
  bool isRunning = false;
  String? status;
  Future<void> _getAttendanceData() async {
    String resp = await getAttendanceData(widget.roommateData,
        widget.hostelName, widget.roomName, widget.selectedDate);
    if (mounted) {
      setState(() {
        status = resp;
      });
    }
    return;
  }

  void pushAgain() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => RoomsScreen(hostelName: widget.hostelName),
    ));
  }

  void onChangeScreen(UserData user, BuildContext ctx) async {
    final value = await Navigator.of(ctx).push(MaterialPageRoute(
        builder: (_) => CompleteDetails(
            user: user,
            hostelName: widget.hostelName,
            roomName: widget.roomName,
            roommateData: widget.roommateData)));
    if (value == null) {
      return;
    }

    if (value == true) {
      if (mounted) {
        setState(() {
          isOnScreen = false;
        });
      }
      pushAgain();
    }
  }

  var currentIcon = const Icon(Icons.close_rounded, color: Colors.red);
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    return isOnScreen
        ? UserBuilder(
            email: widget.roommateData.email,
            loadingWidget: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: circularProgressIndicator(),
              ),
            ),
            builder: (context, user) {
              return GestureDetector(
                onTap: () {
                  onChangeScreen(user, context);
                },
                child: ListTile(
                    leading: CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: user.imgUrl == null
                                ? null
                                : CachedNetworkImage(
                                    imageUrl: user.imgUrl!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )),
                    title: Text(
                      user.name ?? widget.roommateData.email,
                      style: const TextStyle(fontSize: 16),
                    ),
                    contentPadding: EdgeInsets.all(widthScreen * 0.002),
                    subtitle: Text(
                      user.email!.substring(0, 9).toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: status == null
                        ? null
                        : AttendanceIcon(
                            roommateData: widget.roommateData,
                            selectedDate: widget.selectedDate,
                            roomName: widget.roomName,
                            hostelName: widget.hostelName,
                            status: status!)),
              );
            },
          )
        : Container();
  }
}
