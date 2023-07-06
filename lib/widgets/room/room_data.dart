import 'package:flutter/material.dart';

import '../../models/attendance.dart';
import '../../models/hostel/rooms/room.dart';
import '../../screens/hostel/rooms/roommate_form.dart';
import '../../tools.dart';
import 'roommates/roommate_list.dart';

class RoomDataWidget extends StatefulWidget {
  RoomDataWidget(
      {super.key,
      required this.roomData,
      required this.hostelName,
      required this.selectedDate});
  Room roomData;
  String hostelName;
  ValueNotifier<DateTime> selectedDate;
  @override
  State<RoomDataWidget> createState() => _RoomDataWidgetState();
}

class _RoomDataWidgetState extends State<RoomDataWidget> {
  bool isOpen = false;
  bool isRunning = false;
  bool allPresent = false;
  bool isDisabled = false;
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(widthScreen * 0.01),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.roomData.roomName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capacity: ${widget.roomData.capacity}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isDisabled && widget.roomData.numberOfRoommates > 0)
                    IconButton(
                      onPressed: isDisabled
                          ? null
                          : () async {
                              final response = await askUser(
                                context,
                                'Are you sure to mark everyone ${allPresent ? 'absent' : 'present'} ?',
                                yes: true,
                                no: true,
                              );
                              if (response == 'yes') {
                                setState(() {
                                  isDisabled = true;
                                });
                                final resp = await markAllRoommateAttendance(
                                    widget.hostelName,
                                    widget.roomData.roomName,
                                    allPresent ? false : true,
                                    widget.selectedDate.value);
                                if (resp && mounted) {
                                  setState(() {
                                    allPresent = !allPresent;
                                    isDisabled = false;
                                  });
                                } else if (!resp) {
                                  showMsg(
                                      context, 'Unable to perform. Try again');
                                }
                              }
                            },
                      icon:
                          Icon(allPresent ? Icons.cancel : Icons.check_circle),
                    ),
                  if (widget.roomData.capacity >
                      widget.roomData.numberOfRoommates)
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => RoommateForm(
                                  capacity: widget.roomData.capacity,
                                  hostelName: widget.hostelName,
                                  roomName: widget.roomData.roomName,
                                  numRoommates:
                                      widget.roomData.numberOfRoommates,
                                )));
                      },
                      icon: const Icon(Icons.add),
                    ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      isOpen = !isOpen;
                    });
                  },
                  icon: !isOpen
                      ? const Icon(Icons.arrow_drop_down_outlined)
                      : const Icon(Icons.arrow_drop_up_outlined)),
              if (isOpen)
                widget.roomData.numberOfRoommates == 0
                    ? const Center(child: Text("No roommates added yet"))
                    : RoommateWidget(
                        roomData: widget.roomData,
                        selectedDate: widget.selectedDate,
                        hostelName: widget.hostelName,
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
