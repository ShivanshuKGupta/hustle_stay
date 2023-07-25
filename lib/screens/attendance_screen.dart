import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/user.dart';
// import 'package:hustle_stay/models/user.dart';

final _firebase = FirebaseAuth.instance;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen(
      {super.key, this.email, this.hostelName, this.userdata});
  final String? email;
  final String? hostelName;
  final UserData? userdata;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimateIcon(
                    onTap: () {},
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.loading1,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text('Loading...')
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData && snapshot.error != null) {
          return Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimateIcon(
                    onTap: () {},
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.error,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text('No data available')
                ],
              ),
            ),
          );
        }

        return Container();
      },
      future: getUserAttendanceRecord(widget.email ?? currentUser.email!,
          hostelName: widget.hostelName,
          isCurrentUser: widget.email == null ? true : false),
    );
  }

  Widget attendanceWidget(Map<String, dynamic> data) {
    final screenWidth = MediaQuery.of(context).size.height;
    Color tileColor = Colors.white;
    String currentStatus = '';
    switch (data['statistics']['todayStatus']) {
      case 'present':
        tileColor = Colors.greenAccent;
        currentStatus = 'Present';
        break;
      case 'absent':
        tileColor = Colors.redAccent;
        currentStatus = 'Absent';
        break;
      case 'onLeave':
        tileColor = Colors.cyanAccent;
        currentStatus = 'On Leave';
        break;
      case 'presentLate':
        tileColor = Colors.yellowAccent;
        currentStatus = 'Late';
        break;
      case 'onInternship':
        tileColor = Colors.orangeAccent;
        currentStatus = 'on Internship';
        break;
      default:
        tileColor = Colors.deepOrangeAccent;
        currentStatus = 'Not Marked Yet';
    }
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              color: tileColor, // You can change the color based on the status
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            // child: widget.userdata != null
                            //     ? widget.userdata!.imgUrl
                            //     : currentUser.imgUrl == null
                            //         ? const Icon(Icons.person)
                            //         : CachedNetworkImage(
                            //             imageUrl: currentUser.imgUrl!,
                            //             fit: BoxFit.cover,
                            //           ),
                          ),
                        )),
                    const SizedBox(height: 10),
                    Text(
                      currentStatus, // Replace with status (e.g., 'Absent', 'On Campus', etc.)
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    // Add any other designing elements as required (e.g., student's name, ID, etc.)
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add your statistics widgets here, like pie chart, bar chart, data, etc.
                  // For example:
                  Container(
                    width: 200,
                    height: 200,
                    child:
                        Placeholder(), // Replace Placeholder with your actual chart widget
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Attendance Statistics', // Add chart title or any other text here
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
