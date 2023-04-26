import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../models/room.dart';
import '../models/user.dart';

class RoomList extends StatelessWidget {
  final Room room;
  const RoomList({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Text(
          room.id,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...room.getRoomates.map((e) => UserTile(user: e)).toList()
      ]),
    );
  }
}

class UserTile extends StatefulWidget {
  final User user;
  const UserTile({super.key, required this.user});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool isPresent = false;
  @override
  Widget build(BuildContext context) {
    isPresent = dummyAttendance.contains(widget.user.id);
    return ListTile(
      onTap: () {
        setState(() {
          if (isPresent) {
            dummyAttendance.remove(widget.user.id);
          } else {
            dummyAttendance.add(widget.user.id);
          }
        });
      },
      leading: Image.asset(widget.user.img),
      title: Text(
        widget.user.name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: isPresent
          ? const Icon(
              Icons.check_rounded,
              color: Colors.green,
            )
          : const Icon(
              Icons.close_rounded,
              color: Colors.red,
            ),
      subtitle: Text(
        widget.user.id,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
