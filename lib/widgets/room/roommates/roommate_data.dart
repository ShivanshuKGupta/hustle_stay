import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../../screens/profile_view_screen.dart';

class RoommateDataWidget extends StatefulWidget {
  RoommateDataWidget(
      {super.key,
      required this.roommateData,
      required this.hostelName,
      required this.roomName});
  RoommateData roommateData;
  String hostelName;
  String roomName;

  @override
  State<RoommateDataWidget> createState() => _RoommateDataWidgetState();
}

class _RoommateDataWidgetState extends State<RoommateDataWidget> {
  final presentIcon = Icon(Icons.check_circle_outline, color: Colors.green);
  final absentIcon = Icon(Icons.close_rounded, color: Colors.red);

  var currentIcon = Icon(Icons.close_rounded, color: Colors.red);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileViewScreen(
                  userName: widget.roommateData.name,
                  email: widget.roommateData.email,
                  hostelName: widget.hostelName,
                  roomName: widget.roomName,
                )));
      },
      child: ListTile(
          leading: const CircleAvatar(
            backgroundImage: null,
            radius: 50,
          ),
          title: Text(
            widget.roommateData.name,
            style: TextStyle(fontSize: 16),
          ),
          subtitle: Text(
            'Roll No: ${widget.roommateData.rollNumber}',
            style: TextStyle(fontSize: 14),
          ),
          trailing: IconButton(
              onPressed: () {
                setState(() {
                  if (currentIcon == presentIcon) {
                    currentIcon = absentIcon;
                  } else {
                    currentIcon = presentIcon;
                  }
                });
              },
              icon: currentIcon)),
    );
    ;
  }
}
