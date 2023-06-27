import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/chat/call_choser.dart';
import 'package:url_launcher/url_launcher.dart';

class CallButton extends StatelessWidget {
  final List<String> emails;
  final Source? src;
  const CallButton({super.key, required this.emails, this.src});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUsers(emails, src: src),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          Source anotherMethod = Source.cache;
          if (src != anotherMethod) {
            return CallButton(
              emails: emails,
              src: anotherMethod,
            );
          } else {
            return Container(); // Show Nothing
          }
        }
        List<UserData> users = snapshot.data!;
        users.removeWhere((element) => element.phoneNumber == null);
        if (users.isEmpty) {
          return Container();
        }
        return IconButton(
          icon: const Icon(Icons.call_rounded),
          onPressed: () {
            if (users.length == 1) {
              final String url = "tel:+91${users[0].phoneNumber}";
              launchUrl(Uri.parse(url));
            } else {
              Navigator.of(context).push(
                DialogRoute(
                  context: context,
                  builder: (ctx) => CallChoser(phoneNumbers: users),
                ),
              );
            }
          },
        );
      },
    );
  }
}
