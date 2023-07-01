import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/roommates/roommate_data.dart';

import '../../../models/hostel/rooms/room.dart';

class RoommateWidget extends StatefulWidget {
  const RoommateWidget(
      {super.key,
      required this.roomData,
      required this.selectedDate,
      required this.hostelName});
  final Room roomData;
  final ValueNotifier<DateTime> selectedDate;
  final String hostelName;

  @override
  State<RoommateWidget> createState() => _RoommateWidgetState();
}

class _RoommateWidgetState extends State<RoommateWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.roomData.numberOfRoommates,
      itemBuilder: (context, roommateIndex) {
        final roommate = widget.roomData.roomMatesData![roommateIndex];

        return ValueListenableBuilder(
            valueListenable: widget.selectedDate,
            builder: (context, value, child) {
              return RoommateDataWidget(
                roomName: widget.roomData.roomName,
                hostelName: widget.hostelName,
                roommateData: roommate,
                selectedDate: widget.selectedDate.value,
              );
            });
      },
    );
  }
}
