import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';

class VanRequest extends Request {
  DateTime? dateTime;

  static const Map<String, Map<String, dynamic>> uiElements = {
    'Night Travel': {
      'color': Colors.blue,
      'icon': Icons.nightlight_round,
    },
    'Hospital Visit': {
      'color': Colors.tealAccent,
      'icon': Icons.local_hospital_rounded,
    },
    'Other Reason': {
      'color': Colors.lightGreenAccent,
      'icon': Icons.more_horiz_rounded,
    },
  };

  VanRequest({required String requestingUserEmail, this.dateTime}) {
    super.type = "VanRequest";
    super.requestingUserEmail = requestingUserEmail;
  }

  @override
  Map<String, dynamic> encode() {
    return super.encode()
      ..addAll({
        'dateTime': dateTime!.millisecondsSinceEpoch,
      });
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    dateTime = DateTime.fromMillisecondsSinceEpoch(data['dateTime']);
  }

  @override
  bool beforeUpdate() {
    assert(dateTime != null);
    assert(reason.isNotEmpty);
    return super.beforeUpdate();
  }

  @override
  void onApprove() {
    // TODO: send notifications and email etc.
  }

  @override
  Widget widget(BuildContext context) {
    final title = reason.split(':')[0];
    String subtitle = reason.substring(title.length + 2).trim();
    Widget trailing = status == RequestStatus.pending
        ? AnimateIcon(
            onTap: () {
              showMsg(context, 'This request is yet to be approved.');
            },
            iconType: IconType.continueAnimation,
            animateIcon: AnimateIcons.hourglass,
          )
        : Icon(
            status == RequestStatus.approved
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: status == RequestStatus.approved
                ? Colors.greenAccent
                : Colors.redAccent,
          );
    // TODO: remove shortcicuting
    if (currentUser.readonly.type != 'student' && false) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              await approve();
            },
            icon: const Icon(
              Icons.check_rounded,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () async {
              await deny();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    return GlassWidget(
      radius: 30,
      child: Container(
        color: uiElements[title]!['color'].withOpacity(0.2),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          onTap: () {
            navigatorPush(
              context,
              ChatScreen(
                chat: chatData,
              ),
            );
          },
          onLongPress: () {
            showInfo(context);
          },
          leading: Icon(uiElements[title]!['icon'], size: 50),
          title: Text(title),
          trailing: trailing,
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle.isNotEmpty) Text(subtitle),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded),
                  const SizedBox(width: 10),
                  Text(ddmmyyyy(dateTime!)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded),
                  const SizedBox(width: 10),
                  Text(timeFrom(dateTime!)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showInfo(BuildContext context) async {
    final title = reason.split(':')[0];
    String subtitle = reason.substring(title.length + 2).trim();
    final theme = Theme.of(context);
    final response = await Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          scrollable: true,
          actionsPadding: const EdgeInsets.only(bottom: 15, top: 10),
          contentPadding: const EdgeInsets.only(top: 15, left: 20, right: 20),
          content: Column(
            children: [
              Icon(uiElements[title]!['icon']),
              Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "From:",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        // color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    requestingUserEmail,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Requested At:",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        // color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    ddmmyyyy(dateTime!),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final response = await askUser(
                    context, 'Do you really want to withdraw this request?',
                    yes: true, no: true);
                if (response == 'yes') {
                  try {
                    await delete();
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
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Withdraw'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
