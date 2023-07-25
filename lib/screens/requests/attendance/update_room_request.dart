import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/requests/room.dart/update_room.dart';

class UpdateRoom extends StatefulWidget {
  UpdateRoom({super.key, this.isSwap = false, this.hostelName, this.roomName});
  bool isSwap;
  final String? hostelName;
  final String? roomName;

  @override
  State<UpdateRoom> createState() => _UpdateRoomState();
}

class _UpdateRoomState extends State<UpdateRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSwap ? 'Swap Room Request' : 'Change Room Request'),
        actions: [
          IconButton(
            icon: Icon(Icons.reply_all_outlined),
            onPressed: () {
              widget.isSwap = !widget.isSwap;
            },
          )
        ],
      ),
      body: UpdateRoomWidget(
        isSwap: widget.isSwap,
        hostelName: widget.hostelName,
        roomName: widget.roomName,
      ),
    );
  }
}
