import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/hostel/hostels.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:intl/intl.dart';

import '../../../widgets/room/change_room/change_room.dart';

class ProfileViewScreen extends StatefulWidget {
  ProfileViewScreen(
      {super.key,
      required this.hostelName,
      required this.roomName,
      required this.user,
      required this.roommateData});
  String hostelName;
  String roomName;
  UserData user;
  RoommateData roommateData;

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  var destHostelName = "";
  var destRoomName = "";
  bool isRunning = false;
  String? dropdownVal;
  List<DropdownMenuItem> operation = [
    const DropdownMenuItem(
      value: 'Change Room',
      child: Text(
        'Change Room',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10),
      ),
    ),
    const DropdownMenuItem(
      value: "Swap Room",
      child: Text(
        "Swap Room",
        style: TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    )
  ];
  bool onLeave = false;

  @override
  void initState() {
    super.initState();
    onLeave = widget.roommateData.onLeave ?? false;
    fetchLeavesValues();
  }

  LeaveData? currentLeave;
  Future<void> fetchLeavesValues() async {
    LeaveData? cLeave =
        await fetchCurrentLeave(widget.hostelName, widget.roommateData.email);
    List<LeaveData> rLeaves =
        await fetchLeaves(widget.hostelName, widget.roommateData.email);
    setState(() {
      currentLeave = cLeave;
      recentLeaves = rLeaves;
    });
    return;
  }

  List<LeaveData> recentLeaves = [];

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
    double widthScreen = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(widthScreen * 0.03),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                          radius: 50,
                          child: ClipOval(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: widget.user.imgUrl == null
                                  ? null
                                  : CachedNetworkImage(
                                      imageUrl: widget.user.imgUrl!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          )),
                    ),
                    Text(
                      widget.user.email!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const Divider(),
                    Text("Name: ${widget.user.name ?? ''}"),
                    Text("${widget.user.phoneNumber}"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                      end: DateTime.now()
                                          .add(const Duration(days: 1))));

                              if (picked != null) {
                                setState(() {
                                  pickedRangeStart = picked.start.subtract(
                                      const Duration(microseconds: 1));
                                  pickedRangeEnd = picked.end
                                      .add(const Duration(days: 1))
                                      .subtract(
                                          const Duration(microseconds: 1));
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
                                final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: currentLeave!.startDate
                                            .isAfter(DateTime.now())
                                        ? DateTime.now()
                                        : currentLeave!.startDate,
                                    lastDate: DateTime(DateTime.now().year + 1),
                                    initialDateRange: DateTimeRange(
                                        start: currentLeave!.startDate,
                                        end: currentLeave!.endDate));
                                if (picked == null) {
                                  return;
                                }
                                final newPickedRangeStart = picked.start
                                    .subtract(const Duration(microseconds: 1));
                                final newPickedRangeEnd = picked.end
                                    .add(const Duration(days: 1))
                                    .subtract(const Duration(microseconds: 1));

                                await setLeave(
                                    widget.user.email!,
                                    widget.hostelName,
                                    widget.roomName,
                                    true,
                                    true,
                                    leaveStartDate: newPickedRangeStart,
                                    leaveEndDate: newPickedRangeEnd,
                                    data: currentLeave);
                              }
                            },
                            child: LeaveTile(currentLeave!),
                          ),
                        ValueListenableBuilder(
                          valueListenable: reason!,
                          builder: (context, value, child) => TextButton(
                              onPressed: value != "" &&
                                      value != 'Other(please specify)'
                                  ? () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Select/ Enter a reason first!')));
                                    }
                                  : () async {
                                      bool resp = await setLeave(
                                          widget.user.email!,
                                          widget.hostelName,
                                          widget.roomName,
                                          onLeave,
                                          true,
                                          leaveStartDate: onLeave &&
                                                  pickedRangeStart == null
                                              ? null
                                              : pickedRangeStart,
                                          leaveEndDate:
                                              onLeave && pickedRangeEnd == null
                                                  ? null
                                                  : pickedRangeEnd,
                                          reason: onLeave &&
                                                  pickedRangeStart == null
                                              ? null
                                              : reason!.value,
                                          selectedDate: DateTime.now());
                                      if (resp) {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                              child:
                                  Text(!onLeave ? 'Start Leave' : 'End Leave')),
                        ),
                        const Divider(),
                        Column(
                          children: [
                            const Text(
                              'Recent Leaves',
                            ),
                            recentLeaves.isEmpty
                                ? Text('nothing to show...')
                                : listLeaves(recentLeaves),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Divider(),
              Column(
                children: [
                  Center(
                      child: Text(
                    'Edit Hostel/Room',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
                  const SizedBox(
                    height: 15,
                  ),
                  Wrap(
                    children: [
                      Text(
                        'Choose your option',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(
                        width: widthScreen * 0.05,
                      ),
                      DropdownButton(
                          items: operation,
                          value: dropdownVal,
                          onChanged: (value) {
                            setState(() {
                              dropdownVal = value;
                            });
                          }),
                    ],
                  ),
                  if (dropdownVal != null && dropdownVal == 'Change Room')
                    ChangeRoomWidget(
                        isSwap: false,
                        email: widget.user.email!,
                        roomName: widget.roomName,
                        hostelName: widget.hostelName),
                  if (dropdownVal != null && dropdownVal == "Swap Room")
                    ChangeRoomWidget(
                        isSwap: true,
                        email: widget.user.email!,
                        roomName: widget.roomName,
                        hostelName: widget.hostelName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listLeaves(List<LeaveData> list) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return LeaveTile(list[index]);
      },
    );
  }

  Widget LeaveTile(LeaveData dataVal) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(style: BorderStyle.solid, color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataVal.leaveType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Start Date: ${dataVal.startDate.toString()}',
            style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
