import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/attendance_screen.dart';
import 'package:hustle_stay/screens/complaint_screen.dart';
import 'package:hustle_stay/screens/profile_screen.dart';

import '../tools/tools.dart';
import 'add_user_screen.dart';
import 'home_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            leading: currentUser.img == null
                ? const CircleAvatar(child: Icon(Icons.person))
                : Image.network(currentUser.img!),
            title: Text(currentUser.name == null ? "Guest" : currentUser.name!),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(AttendanceScreen.routeName);
            },
            leading: const Icon(Icons.co_present_rounded),
            title: const Text('Attendance'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ComplaintScreen()));
            },
            leading: const Icon(Icons.question_answer_rounded),
            title: const Text('Complaints'),
          ),
          ListTile(
            onTap: () {
              showMsg(context, "Directing to vehicle request page");
            },
            leading: const Icon(Icons.airport_shuttle_rounded),
            title: const Text('Vehicle Request'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(AddUserScreen.routeName);
            },
            leading: const Icon(Icons.supervised_user_circle_rounded),
            title: const Text('Add User'),
          ),
        ],
      ),
    );
  }
}
