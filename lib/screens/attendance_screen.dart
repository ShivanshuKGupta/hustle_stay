import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/screens/requests/attendance/update_room_request.dart';
import 'package:intl/intl.dart';

import '../models/common/operation.dart';
import '../models/user/user.dart';
import '../widgets/requests/grid_tile_logo.dart';
import 'hostel/user/attendance_records.dart';
import 'hostel/user/leave_screen.dart';
import 'hostel/user/statistics.dart';
// import 'package:hustle_stay/models/user.dart';

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
  List<Operations> catList = [
    Operations(
        cardColor: const Color.fromARGB(255, 98, 0, 238),
        operationName: 'View Attendance Records',
        icon: const Icon(
          Icons.calendar_month,
          size: 50,
        )),
    Operations(
        cardColor: const Color.fromARGB(255, 239, 108, 0),
        operationName: 'Statistics and Analytics',
        icon: const Icon(
          Icons.bar_chart_rounded,
          size: 50,
        )),
    Operations(
        cardColor: const Color.fromARGB(255, 238, 0, 0),
        operationName: 'View Leaves',
        icon: const Icon(
          Icons.time_to_leave_rounded,
          size: 50,
        )),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 69),
        operationName: 'Change/Swap Room',
        icon: const Icon(
          Icons.reply_all_sharp,
          size: 50,
        )),
  ];
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
        print(snapshot.data!);
        return attendanceWidget(snapshot.data!);
      },
      future: getStatus(widget.email, widget.userdata != null ? false : true),
    );
  }

  Future<String> getStatus(String? email, bool isCurrentUser) async {
    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(email ?? currentUser.email)
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .get();
    if (ref.exists) {
      return ref['status'];
    }
    return 'noData';
  }

  Widget attendanceWidget(String data) {
    Color tileColor = Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    final brightness = Theme.of(context).brightness;
    String currentStatus = '';
    Icon icon;
    switch (data) {
      case 'present':
        tileColor = Colors.green;
        currentStatus = 'Present';
        icon = const Icon(Icons.check_circle_outline_outlined);
        break;
      case 'absent':
        tileColor = Colors.red;
        currentStatus = 'Absent';
        icon = const Icon(Icons.cancel_outlined);
        break;
      case 'onLeave':
        tileColor = Colors.cyan;
        currentStatus = 'On Leave';
        icon = const Icon(Icons.holiday_village);
        break;
      case 'presentLate':
        tileColor = Colors.yellow;
        currentStatus = 'Late';
        icon = const Icon(Icons.no_accounts);
        break;
      case 'onInternship':
        tileColor = Colors.orange;
        currentStatus = 'on Internship';
        icon = const Icon(Icons.work);
        break;
      default:
        tileColor = Colors.grey;
        currentStatus = 'Not Marked Yet';
        icon = const Icon(Icons.info_sharp);
    }
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height:
                screenWidth >= 800 ? screenheight * 0.6 : screenheight * 0.45,
            padding: EdgeInsets.all(screenWidth >= 800 ? 1 : 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: screenWidth >= 800
                  ? Container(
                      width: screenWidth,
                      height: screenheight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CircleAvatar(
                                radius: 50,
                                child: ClipOval(
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: widget.userdata != null
                                        ? widget.userdata!.imgUrl == null
                                            ? const Icon(Icons.person)
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    widget.userdata!.imgUrl!,
                                                fit: BoxFit.cover,
                                              )
                                        : currentUser.imgUrl == null
                                            ? const Icon(Icons.person)
                                            : CachedNetworkImage(
                                                imageUrl: currentUser.imgUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                  ),
                                )),
                          ),
                          Wrap(
                            direction: Axis.vertical,
                            children: [
                              Text(
                                widget.userdata != null
                                    ? widget.userdata!.name!
                                    : currentUser.name!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenheight * 0.005),
                              Text(
                                widget.userdata != null
                                    ? widget.userdata!.email!
                                    : currentUser.email!,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white54
                                        : Colors.blueGrey),
                              ),
                              SizedBox(height: screenheight * 0.01),
                              Container(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: icon,
                                  label: Text(
                                    currentStatus,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        brightness == Brightness.light
                                            ? tileColor
                                            : tileColor.withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: screenWidth * 0.14,
                            child: ClipOval(
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: widget.userdata != null
                                    ? widget.userdata!.imgUrl == null
                                        ? const Icon(Icons.person)
                                        : CachedNetworkImage(
                                            imageUrl: widget.userdata!.imgUrl!,
                                            fit: BoxFit.cover,
                                          )
                                    : currentUser.imgUrl == null
                                        ? const Icon(Icons.person)
                                        : CachedNetworkImage(
                                            imageUrl: currentUser.imgUrl!,
                                            fit: BoxFit.cover,
                                          ),
                              ),
                            )),
                        SizedBox(height: screenheight * 0.02),
                        Text(
                          widget.userdata != null
                              ? widget.userdata!.name!
                              : currentUser.name!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenheight * 0.005),
                        Text(
                          widget.userdata != null
                              ? widget.userdata!.email!
                              : currentUser.email!,
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white54
                                  : Colors.blueGrey),
                        ),
                        Divider(),
                        SizedBox(height: screenheight * 0.01),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: icon,
                            label: Text(
                              currentStatus,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brightness == Brightness.light
                                  ? tileColor
                                  : tileColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 8, 8),
                  child: GridTileLogo(
                      onTap: () {
                        switch (catList[index].operationName) {
                          case 'View Attendance Records':
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AttendanceRecord()));
                            break;
                          case 'Statistics and Analytics':
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const StatisticsUser()));
                            break;
                          case 'View Leaves':
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const LeaveScreen()));
                            break;
                          case 'Change/Swap Room':
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const UpdateRoom()));
                            break;
                          default:
                        }
                      },
                      title: catList[index].operationName,
                      icon: catList[index].icon!,
                      color: catList[index].cardColor),
                );
              },
              itemCount: catList.length,
            ),
          ),
        ],
      ),
    );
  }
}
