import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:url_launcher/url_launcher.dart';

class CallChoser extends StatefulWidget {
  /// These are users who will definitely have a phone number and
  /// the length of this array would >=1
  final List<UserData> users;
  const CallChoser({super.key, required this.users});

  @override
  State<CallChoser> createState() => _CallChoserState();
}

class _CallChoserState extends State<CallChoser> {
  @override
  void initState() {
    super.initState();
    defaultUser = widget.users[0];
  }

  late UserData defaultUser;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Who to call?'),
      actions: [
        DropdownButton(
          items: widget.users
              .map(
                (user) => DropdownMenuItem(
                  value: user.email,
                  child: Text(user.name ?? user.email!),
                ),
              )
              .toList(),
          value: defaultUser,
          onChanged: ((value) {
            if (value != null) {
              setState(() {
                defaultUser =
                    widget.users.firstWhere((user) => user.email == value);
              });
            }
          }),
        ),
        IconButton(
            onPressed: () {
              launchUrl(Uri.parse("tel:+91${defaultUser.phoneNumber}"));
              final user = widget.users.firstWhere(
                  (element) => element.phoneNumber == defaultUser.phoneNumber);
              showMsg(context, 'Calling ${user.name ?? user.email}');
            },
            icon: const Icon(Icons.call_rounded))
      ],
    );
  }
}
