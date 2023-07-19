import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';

class VanRequest extends Request {
  DateTime? dateTime;

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
    return GlassWidget(
      radius: 30,
      child: Container(
        color: Colors.blue.withOpacity(0.2),
        child: ListTile(
          onTap: () {
            navigatorPush(
              context,
              ChatScreen(
                chat: chatData,
              ),
            );
          },
          leading: const Icon(Icons.nightlight_round, size: 50),
          title: Text(title),
          trailing: status == RequestStatus.pending
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
                ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reason.substring(title.length + 2)),
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
}
