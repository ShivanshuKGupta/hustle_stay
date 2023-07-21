import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';

class SwapRoomRequest extends Request {
  String? targetUserEmail;
  SwapRoomRequest({
    required super.requestingUserEmail,
  }) : super(
          type: 'Swap_Room',
          uiElement: {
            'color': Colors.pinkAccent,
            'icon': Icons.transfer_within_a_station_rounded,
          },
        );

  @override
  Map<String, dynamic> encode() {
    final Map<String, dynamic> ans = super.encode();
    ans['targetUserEmail'] = targetUserEmail;
    return ans;
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    targetUserEmail = data['targetUserEmail']!;
  }

  @override
  bool beforeUpdate() {
    if (targetUserEmail == null) return false;
    targetUserEmail = targetUserEmail!.trim();
    String? err = Validate.email(targetUserEmail, required: true);
    if (err != null) throw err;
    return super.beforeUpdate();
  }

  @override
  void onApprove() {
    // TODO: Sani
    // When request for swapping the room is accepted
    // this function will be called

    // Use [targetUserEmail] and [requestingUserEmail] to complete this function
    // and reason to get some more info
  }

  @override
  Widget widget(context) {
    return super.listWidget(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(children: [
            UserBuilder(
              email: targetUserEmail!,
              builder: (ctx, user) => Text(
                "with ${user.name ?? user.email}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 5),
            if (reason.isNotEmpty)
              Text(
                "| $reason",
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ]),
        ],
      ),
      {
        '-': '-',
        'Swap room with': targetUserEmail!,
      },
    );
  }
}
