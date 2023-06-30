import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/room/roommates/attendance_icon.dart';
import '../../../screens/hostel/rooms/profile_view_screen.dart';
import '../../../tools.dart';

class RoommateDataWidget extends StatefulWidget {
  const RoommateDataWidget(
      {super.key,
      required this.email,
      required this.selectedDate,
      required this.roomName,
      required this.hostelName});
  final String email;
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
    bool resp = await getAttendanceData(
        widget.email, widget.hostelName, widget.roomName, widget.selectedDate);
    setState(() {
      isPresent = resp;
    });
    return;
  }

  var currentIcon = Icon(Icons.close_rounded, color: Colors.red);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserData(widget.email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.error != null) {
                return Center(
                  child: circularProgressIndicator(
                    height: null,
                    width: null,
                  ),
                );
              }
              return RData(snapshot.data!);
            },
            future: fetchUserData(widget.email, src: Source.cache),
          );
        }
        return RData(snapshot.data!);
      },
    );
  }

  Widget RData(UserData user) {
    double widthScreen = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(
                builder: (_) => ProfileViewScreen(
                      user: user,
                      hostelName: widget.hostelName,
                      roomName: widget.roomName,
                    )))
            .then((value) {
          setState(() {});
        });
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
            user.name!,
            style: TextStyle(fontSize: 16),
          ),
          contentPadding: EdgeInsets.all(widthScreen * 0.002),
          subtitle: Text(
            '${user.email!.substring(0, 9).toUpperCase()}',
            style: TextStyle(fontSize: 14),
          ),
          trailing: isPresent == null
              ? null
              : AttendanceIcon(
                  email: widget.email,
                  selectedDate: widget.selectedDate,
                  roomName: widget.roomName,
                  hostelName: widget.hostelName,
                  isPresent: isPresent!)),
    );
  }
}
