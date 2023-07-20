import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';

class RequestBottomBar extends StatelessWidget {
  final Request request;
  const RequestBottomBar({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              if (currentUser.readonly.type != 'student')
                ElevatedButton.icon(
                  onPressed: () async {
                    final response = await askUser(
                        context, 'Do you really want to approve this request?',
                        yes: true, no: true);
                    if (response == 'yes') {
                      try {
                        await request.approve();
                      } catch (e) {
                        if (context.mounted) {
                          showMsg(context, e.toString());
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.green),
                ),
              if (currentUser.readonly.type != 'student')
                ElevatedButton.icon(
                  onPressed: () async {
                    final response = await askUser(
                        context, 'Do you really want to deny this request?',
                        yes: true, no: true);
                    if (response == 'yes') {
                      try {
                        await request.deny();
                      } catch (e) {
                        if (context.mounted) {
                          showMsg(context, e.toString());
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Deny'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                )
            ],
          )),
    );
  }
}
