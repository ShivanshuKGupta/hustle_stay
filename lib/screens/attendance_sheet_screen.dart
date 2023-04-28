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

  Future<void> updateSheet() async {
    await deleteAttendanceSheet(dateChosen, widget.hostelName);
    await uploadAttendanceSheet(dateChosen, currentSheet, widget.hostelName);
  }

  @override
  void initState() {
    super.initState();
    print("hostel chosen: " + widget.hostelName.toString());
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
                        return UserTile(
                          userID: user.rollNo!,
                          name: user.name!,
                          isPresent: isPresent,
                          updateSheet: updateSheet,
                        );
                      },
                    ).toList(),
                  ),
                ),
    );
  }
}

class UserTile extends StatefulWidget {
  final String userID;
  final String name;
  bool isPresent;
  final Future<void> Function() updateSheet;
  UserTile({
    required this.userID,
    required this.name,
    required this.isPresent,
    required this.updateSheet,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        widget.isPresent = !widget.isPresent;
        currentSheet.studentIDList[widget.userID] = widget.isPresent;
        try {
          await widget.updateSheet();
        } catch (e) {
          widget.isPresent = !widget.isPresent;
          currentSheet.studentIDList[widget.userID] = widget.isPresent;
          showMsg(context, e.toString());
          setState(() {
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _isLoading = false;
        });
      },
      leading: const Icon(Icons.person),
      title: Text(
        widget.name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: _isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(),
            )
          : widget.isPresent
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
