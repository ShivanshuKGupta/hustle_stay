import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:url_launcher/url_launcher.dart';

class CallChoser extends StatefulWidget {
  final List<UserData> phoneNumbers;
  const CallChoser({super.key, required this.phoneNumbers});

  @override
  State<CallChoser> createState() => _CallChoserState();
}

class _CallChoserState extends State<CallChoser> {
  @override
  void initState() {
    super.initState();
    phone = widget.phoneNumbers[0].phoneNumber!;
  }

  late String phone;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Who to call?'),
      actions: [
        DropdownButton(
          items: widget.phoneNumbers
              .map(
                (e) => DropdownMenuItem(
                  value: e.phoneNumber!,
                  child: Text(e.name ?? e.email!),
                ),
              )
              .toList(),
          value: phone,
          onChanged: ((value) {
            if (value != null) {
              setState(() {
                phone = value;
              });
            }
          }),
        ),
        IconButton(
            onPressed: () {
              launchUrl(Uri.parse("tel:+91$phone"));
            },
            icon: const Icon(Icons.call_rounded))
      ],
    );
  }
}
