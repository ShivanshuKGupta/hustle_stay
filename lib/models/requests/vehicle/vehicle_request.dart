import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/tools.dart';

class VehicleRequest extends Request {
  DateTime? dateTime;

  VehicleRequest({required String requestingUserEmail, this.dateTime}) {
    super.type = "Vehicle";
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
    final uiElement =
        Request.uiElements[type]!.map((key, value) => MapEntry(key, value));
    uiElement['color'] = Request.uiElements[type]!['children'][title]['color'];
    uiElement['icon'] = Request.uiElements[type]!['children'][title]['icon'];
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
      uiElement,
    );
  }
}
