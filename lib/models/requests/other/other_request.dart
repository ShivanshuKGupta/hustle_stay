import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class OtherRequest extends Request {
  OtherRequest({required super.requestingUserEmail})
      : super(
          type: 'Other',
          uiElement: {
            'color': Colors.amber,
            'icon': Icons.more_horiz_rounded,
          },
        );

  @override
  void onApprove() {
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
