import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/requests/room.dart/update_room.dart';

class UpdateRoom extends StatefulWidget {
  const UpdateRoom(
      {super.key, this.isSwap = false, this.hostelName, this.roomName});
  final bool isSwap;
  final String? hostelName;
  final String? roomName;

  @override
  State<UpdateRoom> createState() => _UpdateRoomState();
}

class _UpdateRoomState extends State<UpdateRoom> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSwap = widget.isSwap;
  }

  bool isSwap = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSwap ? 'Swap Room Request' : 'Change Room Request'),
        actions: [
          IconButton(
            icon: Icon(Icons.reply_all_outlined),
            onPressed: () {
              setState(() {
                isSwap = !isSwap;
              });
            },
          )
        ],
      ),
      body: UpdateRoomWidget(
        isSwap: isSwap,
        hostelName: widget.hostelName,
        roomName: widget.roomName,
      ),
    );
  }
}
