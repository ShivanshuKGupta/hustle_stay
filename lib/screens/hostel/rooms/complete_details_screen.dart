import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/hostel/rooms/profile_view_screen.dart';
import 'package:hustle_stay/widgets/room/leave_widget.dart';
import 'package:hustle_stay/widgets/room/roommates/chart_attendance.dart';

import '../../../models/hostel/rooms/room.dart';
import '../../../models/user.dart';
import '../../../tools.dart';

class CompleteDetails extends StatefulWidget {
  const CompleteDetails(
      {super.key,
      required this.hostelName,
      required this.roomName,
      required this.user,
      required this.roommateData});
  final String hostelName;
  final String roomName;
  final UserData user;
  final RoommateData roommateData;
  @override
  State<CompleteDetails> createState() => _CompleteDetailsState();
}

class _CompleteDetailsState extends State<CompleteDetails> {
  bool isDeleting = false;
  bool showStats = !currentUser.readonly.isAdmin;
  bool showLeaveData = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: shaderText(
            context,
            title: currentUser.readonly.isAdmin
                ? '${widget.user.name ?? widget.user.email}\'s Profile'
                : 'Your Attendance Records',
          ),
          actions: [
            if (!isDeleting)
              IconButton(
                onPressed: () {
                  setState(() {
                    showLeaveData = !showLeaveData;
                  });
                },
                icon: Icon(Icons.holiday_village),
              ),
            if (!isDeleting)
              IconButton(
                  onPressed: () {
                    setState(() {
                      showStats = !showStats;
                    });
                  },
                  icon: showStats
                      ? const Icon(Icons.person)
                      : const Icon(Icons.bar_chart_rounded)),
            if (!isDeleting && currentUser.readonly.isAdmin)
              IconButton(
                  onPressed: () async {
                    final response = await askUser(
                      context,
                      'Are you sure, The Deleted Records won\'t be retrieved ?',
                      yes: true,
                      no: true,
                    );
                    if (response == 'yes') {
                      setState(() {
                        isDeleting = true;
                      });
                      if (await deleteRoommate(widget.user.email!,
                          widget.hostelName, widget.roomName)) {
                        Navigator.of(context).pop(true);
                      } else {
                        setState(() {
                          isDeleting = false;
                        });
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Error deleting ${widget.user.name ?? widget.user.email}. Try again later.")));
                      }
                    }
                  },
                  icon: const Icon(Icons.delete))
          ],
        ),
        body: isDeleting
            ? Center(
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
                        animateIcon: AnimateIcons.trashBin,
                      ),
                      const Text('Deletion in progress!')
                    ],
                  ),
                ),
              )
            : showLeaveData
                ? LeaveWidget(
                    hostelName: widget.hostelName,
                    roomName: widget.roomName,
                    user: widget.user,
                    roommateData: widget.roommateData)
                : toShowWidget());
  }

  Widget toShowWidget() {
    return showStats
        ? AttendancePieChart(
            email: widget.user.email!,
            hostelName: widget.hostelName,
            roomName: widget.roomName)
        : ProfileViewScreen(
            hostelName: widget.hostelName,
            roomName: widget.roomName,
            user: widget.user,
            roommateData: widget.roommateData);
  }
}
