import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/attendance_hostel_screen.dart';

import '../tools.dart';
import 'attendance_screen.dart';
import 'home_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(16))),
            onTap: () {
              showMsg(context, 'Directing to profile page');
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text('Guest'),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => HomeScreen()));
            },
            leading: Icon(Icons.home_rounded),
            title: const Text('Home'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => HostelScreen()));
            },
            leading: Icon(Icons.co_present_rounded),
            title: const Text('Attendance'),
          ),
          ListTile(
            onTap: () {
              showMsg(context, "Directing to complaints page");
            },
            leading: Icon(Icons.question_answer_rounded),
            title: const Text('Complaints'),
          ),
          ListTile(
            onTap: () {
              showMsg(context, "Directing to vehicle request page");
            },
            leading: Icon(Icons.airport_shuttle_rounded),
            title: const Text('Vehicle Request'),
          ),
        ],
      ),
    );
  }
}
