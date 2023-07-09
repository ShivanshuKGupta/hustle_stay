import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/roommates/pie_chart_attendance.dart';

import '../../../tools.dart';

class UserStatistics extends StatefulWidget {
  const UserStatistics(
      {super.key, required this.data, required this.hostelName});
  final Map<String, String> data;
  final String hostelName;

  @override
  State<UserStatistics> createState() => _UserStatisticsState();
}

class _UserStatisticsState extends State<UserStatistics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Rooms"),
      ),
      body: AttendancePieChart(
          hostelName: widget.hostelName, email: widget.data['email']),
    );
  }
}
