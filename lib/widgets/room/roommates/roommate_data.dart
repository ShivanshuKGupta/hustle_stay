import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';
import 'package:hustle_stay/widgets/room/roommates/attendance_icon.dart';

import '../../../screens/hostel/rooms/complete_details_screen.dart';
import '../../../tools.dart';

class RoommateDataWidget extends ConsumerStatefulWidget {
  const RoommateDataWidget(
      {super.key,
      this.roommateData,
      required this.selectedDate,
      this.roomName,
      required this.hostelName,
      this.isNeeded,
      this.status,
      this.email});
  final RoommateData? roommateData;
  final DateTime selectedDate;
  final String hostelName;
  final String? roomName;
  final String? email;
  final bool? isNeeded;
  final String? status;

  @override
  ConsumerState<RoommateDataWidget> createState() => _RoommateDataWidgetState();
}

class _RoommateDataWidgetState extends ConsumerState<RoommateDataWidget> {
  RoommateData? roommateData;
  String? roomName;
  @override
  void didUpdateWidget(covariant RoommateDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.email != null && widget.roommateData == null ||
        widget.roomName == null) {
      getRoommateData(widget.email!, widget.hostelName);
    } else if (widget.isNeeded == null || widget.isNeeded == true) {
      _getAttendanceData();
    } else {
      status = widget.status;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.email != null && widget.roommateData == null ||
        widget.roomName == null) {
      getRoommateData(widget.email!, widget.hostelName);
    } else if (widget.isNeeded == null || widget.isNeeded == true) {
      _getAttendanceData();
    } else {
      status = widget.status;
      tileColor!.value = colorPickerAttendance(widget.status!);
    }
  }

  bool isOnScreen = true;
  ValueNotifier<Color>? tileColor = ValueNotifier(Colors.white);
  bool isRunning = false;
  String? status;
  Future<void> _getAttendanceData() async {
    String resp = await getAttendanceData(widget.roommateData ?? roommateData!,
        widget.hostelName, widget.roomName ?? roomName!, widget.selectedDate);
    if (mounted) {
      setState(() {
        status = resp;
        tileColor!.value = colorPickerAttendance(resp);
      });
    }
    return;
  }

  Future<void> getRoommateData(String email, String hostelName) async {
    final ref = await storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Roommates')
        .doc(email)
        .get();
    if (ref.exists) {
      final data = ref.data();
      final onLeave = data!['onLeave'] ?? false;
      final leaveStartDate = data['leaveStartDate'] as Timestamp?;
      final leaveEndDate = data['leaveEndDate'] as Timestamp?;
      final rData = RoommateData(
        email: ref.id,
        onLeave: onLeave,
        leaveStartDate: leaveStartDate?.toDate(),
        leaveEndDate: leaveEndDate?.toDate(),
      );
      String resp = await getAttendanceData(
          widget.roommateData ?? rData,
          widget.hostelName,
          widget.roomName ?? data['roomName'],
          widget.selectedDate);
      if (mounted) {
        setState(() {
          status = resp;
          roommateData = rData;
          roomName = data['roomName'];
          tileColor!.value = colorPickerAttendance(resp);
        });
      }
    }
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
            roomName: widget.roomName ?? roomName!,
            roommateData: widget.roommateData ?? roommateData!)));
    if (value == null) {
      return;
    }

    if (value == true) {
      if (mounted) {
        setState(() {
          isOnScreen = false;
        });
        pushAgain();
      }
    }
  }

  var currentIcon = const Icon(Icons.close_rounded, color: Colors.red);
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    return isOnScreen
        ? ValueListenableBuilder(
            valueListenable: tileColor!,
            builder: (context, value, child) => UserBuilder(
              email: widget.email ?? widget.roommateData!.email,
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
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.black, style: BorderStyle.solid)),
                        tileColor: (value).withOpacity(0.7),
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
                          user.name ??
                              widget.email ??
                              widget.roommateData!.email,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                        contentPadding: EdgeInsets.all(widthScreen * 0.002),
                        subtitle: Text(
                          user.email!.substring(0, 9).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        trailing: status == null
                            ? null
                            : AttendanceIcon(
                                tileColor: tileColor,
                                roommateData:
                                    widget.roommateData ?? roommateData!,
                                selectedDate: widget.selectedDate,
                                roomName: widget.roomName ?? roomName!,
                                hostelName: widget.hostelName,
                                status: status!)),
                  ),
                );
              },
            ),
          )
        : Container();
  }
}
