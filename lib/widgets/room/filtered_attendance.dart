import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';

class FilteredRecords extends StatefulWidget {
  const FilteredRecords(
      {super.key, required this.email, required this.hostelName});
  final String email;
  final String hostelName;

  @override
  State<FilteredRecords> createState() => _FilteredRecordsState();
}

class _FilteredRecordsState extends State<FilteredRecords> {
  bool isEmpty = false;
  List<AttendanceRecord> list = [];
  @override
  void initState() {
    super.initState();
    filterAttendance();
  }

  @override
  void didUpdateWidget(covariant FilteredRecords oldWidget) {
    super.didUpdateWidget(oldWidget);
    list = [];
    isEmpty = false;
    filterAttendance();
  }

  Future<void> filterAttendance() async {
    final listData =
        await fetchAttendanceByStudent(widget.email, widget.hostelName);
    setState(() {
      if (listData.isEmpty) {
        isEmpty = true;
      } else {
        list = listData;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(list[index].date),
                trailing: list[index].status == 'onLeave'
                    ? Text(
                        'on leave',
                        style: TextStyle(backgroundColor: Colors.yellow[400]),
                      )
                    : Icon(list[index].status == 'present'
                        ? Icons.check_box_rounded
                        : Icons.close),
              );
            },
            itemCount: list.length,
          )
        : const Center(child: Text('loading...'));
  }
}
