import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/roommates/roommate_data.dart';

import '../../../models/room.dart';

class RoommateWidget extends StatefulWidget {
  RoommateWidget({super.key, required this.roomData, required this.hostelName});
  Room roomData;
  String hostelName;

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

        return RoommateDataWidget(
            roomName: widget.roomData.roomName,
            hostelName: widget.hostelName,
            roommateData: roommate);
      },
    );
  }
}
