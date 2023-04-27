import 'package:flutter/material.dart';

import '../widgets/room_list.dart';

class HostelRooms extends StatelessWidget {
  const HostelRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          // children: dummyRooms.map((e) {
          //   return RoomList(room: e);
          // }).toList(),
          ),
    );
  }
}

class _UserTileState extends State<UserTile> {
  bool isPresent = false;
  @override
  Widget build(BuildContext context) {
    // isPresent = dummyAttendance.contains(widget.user.id);
    return ListTile(
        // onTap: () {
        //   setState(() {
        //     // toggle attendance
        //   });
        // },
        // leading: Image.asset(widget.user.img),
        // title: Text(
        //   widget.user.name,
        //   style: Theme.of(context).textTheme.bodyLarge,
        // ),
        // trailing: isPresent
        //     ? const Icon(
        //         Icons.check_rounded,
        //         color: Colors.green,
        //       )
        //     : const Icon(
        //         Icons.close_rounded,
        //         color: Colors.red,
        //       ),
        // subtitle: Text(
        //   widget.user.id,
        //   style: Theme.of(context).textTheme.bodyMedium,
        // ),
        );
  }
}
