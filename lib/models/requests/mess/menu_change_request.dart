import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class MenuChangeRequest extends Request {
  MenuChangeRequest({
    required super.requestingUserEmail,
  }) : super(
          type: "Menu_Change",
          uiElement: {
            'color': Colors.pinkAccent,
            'icon': Icons.restaurant,
          },
        );

  @override
  Future<void> onApprove(transaction) async {
    // TODO: send notifications and email etc.
  }

  @override
  Widget widget(BuildContext context) {
    return super.listWidget(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reason.isNotEmpty)
            Text(
              reason,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      {},
    );
  }
}
