import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/roommates/chart_attendance.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, required this.hostelName});
  final String hostelName;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics and Analytics'),
        actions: [
          IconButton(
              onPressed: () async {
                final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now());
                if (picked != null) {
                  selectedDate.value = picked;
                }
              },
              icon: Icon(Icons.calendar_month))
        ],
      ),
      body: AttendancePieChart(
          hostelName: widget.hostelName, selectedDate: selectedDate),
    );
  }
}
