import 'package:flutter/material.dart';
import 'package:hustle_stay/dummy_data.dart';
import '../models/user.dart';

class AttendanceScreen extends StatelessWidget {
  static const String routeName = "attendance_screen";
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text('Attendance'),
      ),
      backgroundColor: Colors.white70,
      body: Room(),
    );
  }
}

class Room extends StatelessWidget {
  const Room({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: UserTile(user: dummy_users[0]),
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Image.asset(user.img),
      title: Text(user.name),
      subtitle: Text(user.id),
    );
  }
}
