import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/attendance.dart';

class AttendanceSheetScreen extends ConsumerStatefulWidget {
  final String hostelName;
  const AttendanceSheetScreen({super.key, required this.hostelName});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AttendanceSheetScreen();
  }
}

class _AttendanceSheetScreen extends ConsumerState<AttendanceSheetScreen> {
  DateTime dateChosen = DateTime.now();

  bool _isLoading = false;
  AttendanceSheet attendanceSheet = AttendanceSheet();

  getSheet() async {
    setState(() {
      _isLoading = true;
    });
    try {
      attendanceSheet = await fetchAttendanceSheet(dateChosen);
      ;
    } catch (e) {
      await createAttendanceSheet(dateChosen);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    getSheet();
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
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Creating an attendance sheet'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                  // children: attendanceSheet.sheet.entries.map(
                  //   (e) {
                  //     return UserTile(e.key);
                  //   },
                  // ).toList(),
                  ),
            ),
    );
  }
}

class UserTile extends StatefulWidget {
  String userID;
  UserTile(this.userID);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool isPresent = false;

  @override
  Widget build(BuildContext context) {
    // isPresent = dummyAttendance.contains(widget.user.id);

    return ListTile(
      onTap: () {
        setState(() {
          // toggle attendance
        });
      },
      // leading: Image.asset(widget.user.img),
      title: Text(
        widget.userID,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: isPresent
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
