import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';

import '../../models/attendance.dart';
import '../../models/hostel/hostels.dart';
import '../../models/hostel/rooms/room.dart';
import '../../models/user/user.dart';
import '../../screens/hostel/rooms/rooms_screen.dart';
import '../../tools.dart';

class LeaveWidget extends StatefulWidget {
  const LeaveWidget(
      {super.key,
      required this.hostelName,
      required this.roomName,
      required this.user,
      required this.roommateData});
  final String hostelName;
  final String roomName;
  final UserData user;
  final RoommateData roommateData;

  @override
  State<LeaveWidget> createState() => _LeaveWidgetState();
}

class _LeaveWidgetState extends State<LeaveWidget> {
  List<LeaveData> recentLeaves = [];
  bool onLeave = false;

  @override
  void initState() {
    super.initState();
    onLeave = widget.roommateData.leaveStartDate == null &&
            widget.roommateData.leaveEndDate == null
        ? false
        : true;
    if (onLeave == true &&
        DateTime.now().isAfter(widget.roommateData.leaveEndDate!)) {
      onLeave = false;
      endLeave();
    }
    fetchLeavesValues();
  }

  Future<void> endLeave() async {
    await updateLeaveStatus(widget.roommateData.email, widget.hostelName);
    getAttendanceData(widget.roommateData, widget.hostelName, widget.roomName,
        DateTime.now());

    return;
  }

  LeaveData? currentLeave;
  Future<void> fetchLeavesValues() async {
    LeaveData? cLeave;
    if (onLeave) {
      cLeave =
          await fetchCurrentLeave(widget.hostelName, widget.roommateData.email);
    }
    List<LeaveData> rLeaves =
        await fetchLeaves(widget.hostelName, widget.roommateData.email);
    setState(() {
      currentLeave = cLeave;
      recentLeaves = rLeaves;
    });
    return;
  }

  List<DropdownMenuEntry> listDropDown = [
    const DropdownMenuEntry(value: 'Internship', label: 'Internship'),
    const DropdownMenuEntry(
        value: 'Family Emergency', label: 'Family Emergency'),
    const DropdownMenuEntry(value: 'Mid-Sem Break', label: 'Mid-Sem Break'),
    const DropdownMenuEntry(value: 'End-Sem Break', label: 'End-Sem Break'),
    const DropdownMenuEntry(
        value: 'Medical Issue/Emergency', label: 'Medical Issue/Emergency'),
    const DropdownMenuEntry(
        value: 'Other(please specify)', label: 'Other(please specify)')
  ];

  DateTime? pickedRangeStart;
  DateTime? pickedRangeEnd;
  ValueNotifier<String>? reason = ValueNotifier("");
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        onLeave ? Text('Your Current Leave') : Text('Add new Leave'),
        if (!onLeave)
          IconButton(
            alignment: Alignment.center,
            onPressed: () async {
              final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1),
                  initialDateRange: DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now().add(const Duration(days: 1))));

              if (picked != null) {
                setState(() {
                  pickedRangeStart =
                      picked.start.subtract(const Duration(microseconds: 1));
                  pickedRangeEnd = picked.end
                      .add(const Duration(days: 1))
                      .subtract(const Duration(microseconds: 1));
                });
              }
            },
            icon: const Icon(Icons.calendar_today),
          ),
        if (!onLeave)
          DropdownMenu(
            dropdownMenuEntries: listDropDown,
            onSelected: (value) {
              reason!.value = value;
            },
          ),
        if (!onLeave)
          TextField(
            onChanged: (value) {
              reason!.value = value;
            },
            decoration: const InputDecoration(
                hintText:
                    'Reason (Optional if chosen any option except Others.)'),
          ),
        if (onLeave && currentLeave != null)
          GestureDetector(
            onLongPress: () async {
              final response = await askUser(
                context,
                'Want to update the Dates?',
                yes: true,
                no: true,
              );
              if (response == 'yes') {
                // ignore: use_build_context_synchronously
                final picked = await showDateRangePicker(
                    context: context,
                    firstDate: currentLeave!.startDate.isAfter(DateTime.now())
                        ? DateTime.now()
                        : currentLeave!.startDate,
                    lastDate: DateTime(DateTime.now().year + 1),
                    initialDateRange: DateTimeRange(
                        start: currentLeave!.startDate,
                        end: currentLeave!.endDate));
                if (picked == null) {
                  return;
                }
                final newPickedRangeStart =
                    picked.start.subtract(const Duration(microseconds: 1));
                final newPickedRangeEnd = picked.end
                    .add(const Duration(days: 1))
                    .subtract(const Duration(microseconds: 1));

                final resp = await setLeave(
                    widget.user.email!, widget.hostelName, true, false,
                    leaveStartDate: newPickedRangeStart,
                    leaveEndDate: newPickedRangeEnd,
                    data: currentLeave);
                if (resp) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(true);
                }
              }
            },
            child: LeaveTile(currentLeave!),
          ),
        ValueListenableBuilder(
          valueListenable: reason!,
          builder: (context, value, child) => TextButton(
              onPressed: !onLeave &&
                      (value == "" ||
                          value == 'Other(please specify)' ||
                          pickedRangeEnd == null)
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(pickedRangeEnd == null
                              ? 'Select Dates to continue!'
                              : 'Select/ Enter a reason first!')));
                    }
                  : () async {
                      bool resp = await setLeave(widget.user.email!,
                          widget.hostelName, onLeave, onLeave,
                          leaveStartDate: onLeave && pickedRangeStart == null
                              ? null
                              : pickedRangeStart,
                          leaveEndDate: onLeave && pickedRangeEnd == null
                              ? null
                              : pickedRangeEnd,
                          reason: onLeave && pickedRangeStart == null
                              ? null
                              : reason!.value,
                          selectedDate: DateTime.now());
                      if (resp) {
                        Navigator.of(context).pop(true);
                      }
                    },
              child: Text(!onLeave ? 'Start Leave' : 'End Leave')),
        ),
        const Divider(),
        const Text(
          'Recent Leaves',
        ),
        recentLeaves.isEmpty
            ? Expanded(
                child: Center(
                    child: Column(
                children: [
                  AnimateIcon(
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.confused),
                  Text('nothing to show...'),
                ],
              )))
            : listLeaves(recentLeaves),
      ],
    );
  }

  Widget listLeaves(List<LeaveData> list) {
    return Expanded(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return LeaveTile(list[index]);
        },
      ),
    );
  }

  Widget LeaveTile(LeaveData dataVal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(style: BorderStyle.solid, color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataVal.leaveType,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Start Date: ${dataVal.startDate.toString()}',
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
          const SizedBox(height: 4.0),
          Text(
            'End Date: ${dataVal.endDate.toString()}',
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
