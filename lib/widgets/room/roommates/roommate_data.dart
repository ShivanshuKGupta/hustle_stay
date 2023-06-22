import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../../screens/profile_view_screen.dart';

class RoommateDataWidget extends StatefulWidget {
  RoommateDataWidget({super.key, required this.roommateData});
  RoommateData roommateData;

  @override
  State<RoommateDataWidget> createState() => _RoommateDataWidgetState();
}

class _RoommateDataWidgetState extends State<RoommateDataWidget> {
  final presentIcon = Icon(Icons.check_circle_outline, color: Colors.green);
  final absentIcon = Icon(Icons.close_rounded, color: Colors.red);

  var currentIcon = Icon(Icons.close_rounded, color: Colors.red);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ProfileViewScreen(email: widget.roommateData.email)));
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
