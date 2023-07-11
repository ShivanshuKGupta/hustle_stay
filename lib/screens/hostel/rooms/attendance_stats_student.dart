import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';

import '../../../models/attendance.dart';

class AttendanceStudent extends StatefulWidget {
  const AttendanceStudent(
      {super.key,
      required this.hostelName,
      required this.email,
      required this.status});
  final String hostelName;
  final String email;
  final String status;

  @override
  State<AttendanceStudent> createState() => _AttendanceStudentState();
}

class _AttendanceStudentState extends State<AttendanceStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Data'),
      ),
      body: FutureBuilder(
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
          return listData(snapshot.data!);
        },
        future: fetchAttendanceByStudent(
            widget.email, widget.hostelName, widget.status),
      ),
    );
  }

  Widget listData(List<DateTime> list) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].toString()),
          trailing: widget.status == 'onLeave'
              ? Text(
                  'on leave',
                  style: TextStyle(backgroundColor: Colors.yellow[400]),
                )
              : Icon(widget.status == 'present'
                  ? Icons.check_box_rounded
                  : Icons.close),
        );
      },
      itemCount: list.length,
    );
  }
}
