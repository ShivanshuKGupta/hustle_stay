import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../widgets/room_list.dart';

class HostelRooms extends StatelessWidget {
  const HostelRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: dummyRooms.map((e) {
          return RoomList(room: e);
        }).toList(),
      ),
    );
  }
}
