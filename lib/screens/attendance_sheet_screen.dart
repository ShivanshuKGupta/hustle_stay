import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools/user_tools.dart';

import '../tools/tools.dart';

class AttendanceSheetScreen extends StatefulWidget {
  final String hostelName;
  const AttendanceSheetScreen({super.key, required this.hostelName});
  @override
  State<StatefulWidget> createState() {
    return _AttendanceSheetScreen();
  }
}

class _AttendanceSheetScreen extends State<AttendanceSheetScreen> {
  DateTime dateChosen = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getSheet();
  }

  getSheet() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await fetchAttendanceSheet(dateChosen, widget.hostelName);
      if (currentSheet.studentIDList.isEmpty) {
        currentSheet = createAttendanceSheet(dateChosen, widget.hostelName);
        await uploadAttendanceSheet(
            dateChosen, currentSheet, widget.hostelName);
        await fetchAttendanceSheet(dateChosen, widget.hostelName);
        if (currentSheet.studentIDList.isEmpty) {
          print("No hostelers");
        }
      }
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: dateChosen,
                firstDate: DateTime.utc(2000),
                lastDate: DateTime.now(),
              ).then((value) {
                if (value != null) dateChosen = value;
                getSheet();
              });
            },
            icon: const Icon(Icons.date_range_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Loading attendance sheet'),
                ],
              ),
            )
          : currentSheet.studentIDList.isEmpty
              ? Center(
                  child: Text(
                    'No Hostelers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: currentSheet.studentIDList.entries.map(
                      (entry) {
                        final userID = entry.key;
                        final isPresent = entry.value;
                        User user = allUsers
                            .firstWhere((element) => element.rollNo == userID);
                        return UserTile(user.rollNo!, user.name!, isPresent);
                      },
                    ).toList(),
                  ),
                ),
    );
  }
}

class UserTile extends StatefulWidget {
  String userID;
  String name;
  bool isPresent;
  UserTile(this.userID, this.name, this.isPresent);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          // toggleAttendance();
          widget.isPresent = !widget.isPresent;
        });
      },
      leading: const Icon(Icons.person),
      title: Text(
        widget.name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: widget.isPresent
          ? const Icon(
              Icons.check_rounded,
              color: Colors.green,
            )
          : const Icon(
              Icons.close_rounded,
              color: Colors.red,
            ),
      subtitle: Text(
        widget.userID,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
