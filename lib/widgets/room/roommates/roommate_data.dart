import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/room/roommates/attendance_icon.dart';

import '../../../screens/hostel/rooms/profile_view_screen.dart';
import '../../../tools.dart';

class RoommateDataWidget extends StatefulWidget {
  const RoommateDataWidget(
      {super.key,
      required this.roommateData,
      required this.selectedDate,
      required this.roomName,
      required this.hostelName});
  final RoommateData roommateData;
  final DateTime selectedDate;
  final String hostelName;
  final String roomName;

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
    _getAttendanceData();
  }

  bool isRunning = false;
  bool? isPresent;
  Future<void> _getAttendanceData() async {
    bool resp = await getAttendanceData(widget.roommateData.email,
        widget.hostelName, widget.roomName, widget.selectedDate);
    setState(() {
      isPresent = resp;
    });
    return;
  }

  var currentIcon = const Icon(Icons.close_rounded, color: Colors.red);
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    return UserBuilder(
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => ProfileViewScreen(
                    user: user,
                    hostelName: widget.hostelName,
                    roomName: widget.roomName,
                    roommateData: widget.roommateData)));
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
              trailing: isPresent == null
                  ? null
                  : AttendanceIcon(
                      email: widget.roommateData.email,
                      selectedDate: widget.selectedDate,
                      roomName: widget.roomName,
                      hostelName: widget.hostelName,
                      isPresent: isPresent!)),
        );
      },
    );
  }
}
