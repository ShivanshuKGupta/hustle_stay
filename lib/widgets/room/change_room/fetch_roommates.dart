import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/change_room/swap_room.dart';

import '../../../models/hostel/rooms/room.dart';
import '../../../tools.dart';

class FetchRoommates extends StatefulWidget {
  FetchRoommates(
      {super.key,
      required this.destRoomName,
      required this.isSwap,
      required this.destHostelName,
      required this.email,
      required this.roomName,
      required this.hostelName});
  String destHostelName;
  String destRoomName;
  String email;
  String roomName;
  String hostelName;
  bool isSwap;
  @override
  State<FetchRoommates> createState() => _FetchRoommatesState();
}

class _FetchRoommatesState extends State<FetchRoommates> {
  String? destRoommateEmail;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchRoommateNames(widget.destHostelName, widget.destRoomName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: circularProgressIndicator(
              height: 2,
              width: 2,
            ),
          );
        }
        return NamesDropDown(snapshot.data!);
      },
    );
  }

  Widget NamesDropDown(List<DropdownMenuItem> list) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Text(
                'Roommate to swap',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                width: 5,
              ),
              DropdownButton(
                  items: list,
                  value: destRoommateEmail,
                  onChanged: (value) {
                    setState(() {
                      destRoommateEmail = value;
                    });
                  }),
            ],
          ),
        ),
        if (destRoommateEmail != null && destRoommateEmail != '')
          SwapRoom(
              destRoomName: widget.destRoomName,
              isSwap: widget.isSwap,
              destHostelName: widget.destHostelName,
              email: widget.email,
              roomName: widget.roomName,
              hostelName: widget.hostelName,
              destRoommateEmail: destRoommateEmail!)
      ],
    );
  }
}
