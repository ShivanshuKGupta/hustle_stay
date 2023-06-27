import 'package:flutter/material.dart';

import '../../../models/hostel/rooms/room.dart';
import '../../../tools.dart';
import '../../../widgets/form/addroom_form.dart';

class AddRoom extends StatelessWidget {
  AddRoom({super.key, required this.hostelName});
  String hostelName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: 'Add Room',
        ),
      ),
      body: AddRoomWid(
        hostelName: hostelName,
      ),
    );
  }
}
