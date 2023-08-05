import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/screens/requests/attendance/update_room_request.dart';
import 'package:intl/intl.dart';

import '../models/common/operation.dart';
import '../models/user/user.dart';
import 'hostel/hostel_screen.dart';
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
        icon: const Icon(Icons.calendar_month)),
    Operations(
        cardColor: const Color.fromARGB(255, 239, 108, 0),
        operationName: 'Statistics and Analytics',
        icon: const Icon(Icons.bar_chart_rounded)),
    Operations(
        cardColor: const Color.fromARGB(255, 238, 0, 0),
        operationName: 'View Leaves',
        icon: const Icon(Icons.time_to_leave_rounded)),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 69),
        operationName: 'Change/Swap Room',
        icon: const Icon(Icons.reply_all_sharp)),
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
        .collection('hostels')
        .doc('hostelMates')
        .collection('Roommates')
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
        tileColor = Colors.deepOrange;
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
              color: brightness == Brightness.dark
                  ? tileColor
                  : tileColor.withOpacity(0.4),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final Color cardColor = catList[index].cardColor;
                LinearGradient? gradient;
                gradient = LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: brightness == Brightness.light
                      ? [
                          cardColor.withOpacity(0.2),
                          Colors.white,
                        ]
                      : [
                          cardColor.withOpacity(0.7),
                          Colors.black,
                        ],
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 8, 8),
                  child: GestureDetector(
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
                      child: Container(
                        width: screenWidth,
                        padding: EdgeInsets.all(
                            catList[index].imgUrl != null ? 4 : 1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient:
                              brightness == Brightness.light ? null : gradient,
                          color: brightness == Brightness.light
                              ? cardColor.withOpacity(0.2)
                              : null,
                          boxShadow: catList[index].imgUrl != null ||
                                  brightness == Brightness.light
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: catList[index].imgUrl == null
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.end,
                          children: [
                            if (catList[index].imgUrl == null)
                              Expanded(
                                child: Icon(
                                  catList[index].icon!.icon,
                                  size: screenWidth * 0.3,
                                ),
                              ),
                            if (catList[index].imgUrl != null)
                              Expanded(
                                  child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: catList[index].imgUrl!,
                                  fit: BoxFit.cover,
                                  width: screenWidth - 8,
                                ),
                              )),
                            Divider(
                              color: brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            Text(
                              catList[index].operationName,
                              overflow: TextOverflow.clip,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: brightness == Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                            ),
                            Divider(
                              color: brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ],
                        ),
                      )),
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
