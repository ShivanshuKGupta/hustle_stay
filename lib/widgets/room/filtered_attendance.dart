import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';

class FilteredRecords extends StatefulWidget {
  FilteredRecords({super.key, required this.email});
  String email;

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
    final listData = await fetchAttendanceByStudent(widget.email);
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
                trailing: Icon(list[index].isPresent
                    ? Icons.check_box_rounded
                    : Icons.close),
              );
            },
            itemCount: list.length,
          )
        : const Center(child: Text('loading...'));
  }
}
