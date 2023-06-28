import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/user.dart';
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
  // attendanceRecord= FirebaseFirestore.instance.collection('hostels').doc(widget.hostelName).collection('Rooms').doc(widget.roomName).collection('Roommates').doc(widget.roommateData.email).collection('Attendance');
  final presentIcon = Icon(Icons.check_circle_outline, color: Colors.green);
  final absentIcon = Icon(Icons.close_rounded, color: Colors.red);
  bool isRunning = false;
  bool isPresent = false;
  @override
  // void initState() async {
  //   // TODO: implement initState
  //   super.initState();
  //   bool resp = await getAttendanceData(
  //       widget.email, widget.hostelName, widget.roomName, widget.selectedDate);
  //   setState(() {
  //     isPresent = resp;
  //   });
  // }

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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileViewScreen(
                  user: user,
                  hostelName: user.hostelName!,
                  roomName: user.roomName!,
                )));
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
          subtitle: Text(
            'Roll No: ${user.email!.substring(0, 9).toUpperCase()}',
            style: TextStyle(fontSize: 14),
          ),
          trailing: IconButton(
              onPressed: () {
                // setAttendanceData(
                //     widget.email,
                //     widget.hostelName,
                //     widget.roomName,
                //     widget.selectedDate,
                //     currentIcon == presentIcon);
                setState(() {
                  if (currentIcon == presentIcon) {
                    currentIcon = absentIcon;
                  } else {
                    currentIcon = presentIcon;
                  }
                });
              },
              icon: isPresent ? presentIcon : absentIcon)),
    );
  }
}
