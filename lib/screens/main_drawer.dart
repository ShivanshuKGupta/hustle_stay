import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/providers/user.dart';
import 'package:hustle_stay/screens/attendance_hostel_screen.dart';
import 'package:hustle_stay/screens/login_screen.dart';

import '../tools.dart';
import 'add_user_screen.dart';
import 'attendance_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    return Drawer(
      child: Column(
        children: [
          ListTile(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(16))),
            onTap: () {
              Navigator.of(context).pushNamed(LoginScreen.routeName);
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            leading: user.img == null
                ? const CircleAvatar(child: Icon(Icons.person))
                : Image.network(user.img!),
            title: Text(user.name == null ? "Guest" : user.name!),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => const HomeScreen()));
            },
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => const HostelScreen()));
            },
            leading: const Icon(Icons.co_present_rounded),
            title: const Text('Attendance'),
          ),
          ListTile(
            onTap: () {
              showMsg(context, "Directing to complaints page");
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
