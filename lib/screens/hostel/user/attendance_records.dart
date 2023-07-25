import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';

import '../../../models/attendance.dart';

class AttendanceRecord extends StatefulWidget {
  const AttendanceRecord({super.key, this.email});
  final String? email;

  @override
  State<AttendanceRecord> createState() => _AttendanceRecordState();
}

class _AttendanceRecordState extends State<AttendanceRecord> {
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Record'),
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
          return calendarWid(snapshot.data!);
        },
        future: getAttendanceRecord(widget.email),
      ),
    );
  }

  Color? _getAttendanceStatusColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'presentLate':
        return Colors.yellow;
      case 'onLeave':
        return Colors.cyan;
      case 'onInternship':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget calendarWid(Map<DateTime, String> data) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          monthNavigation(),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: width * 0.02,
              crossAxisSpacing: width * 0.02,
            ),
            shrinkWrap: true,
            itemCount: _daysInMonth(_selectedDate.month, _selectedDate.year) +
                _firstWeekdayOfMonth(),
            itemBuilder: (context, index) {
              final day = index - _firstWeekdayOfMonth() + 1;
              final date =
                  DateTime(_selectedDate.year, _selectedDate.month, day);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: day <= 0
                      ? null
                      : BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAttendanceStatusColor(data[date]) ??
                              Colors.grey,
                        ),
                  child: Text(
                    day <= 0 ? "" : day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget monthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedDate = _previousMonth(_selectedDate);
            });
          },
        ),
        Text(
          '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedDate = _nextMonth(_selectedDate);
            });
          },
        ),
      ],
    );
  }

  int _daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  int _firstWeekdayOfMonth() {
    return DateTime(_selectedDate.year, _selectedDate.month, 1).weekday - 1;
  }

  DateTime _previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, date.day);
  }

  DateTime _nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, date.day);
  }

  String _getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
