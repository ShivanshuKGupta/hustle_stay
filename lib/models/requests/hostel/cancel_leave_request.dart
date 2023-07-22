import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class CancelLeaveRequest extends Request {
  CancelLeaveRequest({
    required super.requestingUserEmail,
  }) : super(
          type: 'Cancel_Leave',
          uiElement: {
            'color': Colors.orangeAccent,
            'icon': Icons.free_cancellation_rounded,
          },
        );

  @override
  Future<void> onApprove(transaction) async {
    /// TODO: Sani
  }

  @override
  Widget widget(context) {
    return super.listWidget(
      context,
      Column(
        children: [
          Wrap(children: [
            if (reason.isNotEmpty)
              Text(
                "| $reason",
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ]),
        ],
      ),
      {},
    );
  }
}
