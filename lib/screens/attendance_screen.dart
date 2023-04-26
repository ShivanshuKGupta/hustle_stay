import 'package:flutter/material.dart';
import 'hostel_rooms.dart';
import 'main_drawer.dart';

class AttendanceScreen extends StatelessWidget {
  static const String routeName = "attendance_screen";
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      drawer: MainDrawer(),
      body: HostelRooms(),
    );
  }
}
