import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../screens/roommate_form.dart';
import 'roommates/roommate_list.dart';

class RoomDataWidget extends StatefulWidget {
  RoomDataWidget({super.key, required this.roomData, required this.hostelName});
  Room roomData;
  String hostelName;
  @override
  State<RoomDataWidget> createState() => _RoomDataWidgetState();
}

class _RoomDataWidgetState extends State<RoomDataWidget> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Expanded(
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
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
                    SizedBox(height: 16),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RoommateForm(
                                  capacity: widget.roomData.capacity,
                                  hostelName: widget.hostelName,
                                  roomName: widget.roomData.roomName,
                                  numRoommates:
                                      widget.roomData.numberOfRoommates,
                                )));
                      },
                      icon: Icon(Icons.add),
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
                      ? Center(child: Text("No roommates added yet"))
                      : RoommateWidget(
                          hostelName: widget.hostelName,
                          roomData: widget.roomData,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }
}
