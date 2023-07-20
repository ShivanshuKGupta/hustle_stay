import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';

class OtherRequest extends Request {
  OtherRequest({required String userEmail}) {
    super.requestingUserEmail = userEmail;
    super.type = "Other";
  }

  @override
  void onApprove() {
    // TODO: send notifications and email etc.
  }

  @override
  Widget widget(BuildContext context) {
    final Map<String, dynamic> uiElement = Request.uiElements['Other']!
        .map<String, dynamic>((key, value) => MapEntry(key.toString(), value));
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
      uiElement,
      {},
    );
  }
}
