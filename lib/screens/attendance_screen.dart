import 'package:flutter/material.dart';
import 'package:hustle_stay/dummy_data.dart';
import 'package:hustle_stay/models/room.dart';
import '../models/user.dart';

class AttendanceScreen extends StatelessWidget {
  static const String routeName = "attendance_screen";
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text('Attendance'),
      ),
      backgroundColor: Colors.white70,
      body: SingleChildScrollView(
        child: Column(
          children: dummy_rooms.map((e) {
            return RoomList(room: e);
          }).toList(),
        ),
      ),
    );
  }
}

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
    isPresent = dummy_attendance.contains(widget.user.id);
    return ListTile(
      onTap: () {
        setState(() {
          if (isPresent) {
            dummy_attendance.remove(widget.user.id);
          } else {
            dummy_attendance.add(widget.user.id);
          }
        });
      },
      leading: Image.asset(widget.user.img),
      title: Text(widget.user.name),
      trailing: isPresent
          ? const Icon(
              Icons.check_circle_rounded,
              color: Colors.blue,
            )
          : const Icon(
              Icons.check_circle_outline_rounded,
            ),
      subtitle: Text(widget.user.id),
    );
  }
}
