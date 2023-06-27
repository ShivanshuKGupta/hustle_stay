import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';

import '../../../models/hostel/rooms/room.dart';
import '../../../screens/hostel/rooms/profile_view_screen.dart';
import '../../../tools.dart';

class RoommateDataWidget extends StatefulWidget {
  const RoommateDataWidget({
    super.key,
    required this.email,
  });
  final String email;

  @override
  State<RoommateDataWidget> createState() => _RoommateDataWidgetState();
}

class _RoommateDataWidgetState extends State<RoommateDataWidget> {
  // attendanceRecord= FirebaseFirestore.instance.collection('hostels').doc(widget.hostelName).collection('Rooms').doc(widget.roomName).collection('Roommates').doc(widget.roommateData.email).collection('Attendance');
  final presentIcon = Icon(Icons.check_circle_outline, color: Colors.green);
  final absentIcon = Icon(Icons.close_rounded, color: Colors.red);
  bool isRunning = false;

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
                  child: CachedNetworkImage(
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
                setState(() {
                  if (currentIcon == presentIcon) {
                    currentIcon = absentIcon;
                  } else {
                    currentIcon = presentIcon;
                  }
                });
              },
              icon: currentIcon)),
    );
  }
}
