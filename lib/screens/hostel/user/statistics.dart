import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/room/roommates/chart_attendance.dart';

class StatisticsUser extends StatefulWidget {
  const StatisticsUser({super.key});

  @override
  State<StatisticsUser> createState() => _StatisticsUserState();
}

class _StatisticsUserState extends State<StatisticsUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics and Analytics'),
      ),
      body: AttendancePieChart(
        email: currentUser.email,
        hostelName: currentUser.readonly.hostelName!,
      ),
    );
  }
}
