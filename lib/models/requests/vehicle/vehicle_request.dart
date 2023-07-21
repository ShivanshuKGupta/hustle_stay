import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/tools.dart';

class VehicleRequest extends Request {
  DateTime? dateTime;
  late String title;

  VehicleRequest({
    required super.requestingUserEmail,
    this.dateTime,
    required this.title,
  }) : super(
          type: "Vehicle",
          uiElement: {
            'Night_Travel': {
              'color': Colors.blue,
              'icon': Icons.nightlight_round,
              'reasonOptions': [
                'Train Arrival',
                'Train Departure',
              ],
            },
            'Hospital_Visit': {
              'color': Colors.tealAccent,
              'icon': Icons.local_hospital_rounded,
              'reasonOptions': [
                'Fever',
                'Food Poisoning',
              ],
            },
            'Other': {
              'color': Colors.lightGreenAccent,
              'icon': Icons.more_horiz_rounded,
              'reasonOptions': <String>[],
            },
          },
        );

  @override
  Map<String, dynamic> encode() {
    return super.encode()
      ..addAll({
        'dateTime': dateTime!.millisecondsSinceEpoch,
        'title': title,
      });
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    dateTime = DateTime.fromMillisecondsSinceEpoch(data['dateTime']);
    title = data['title'];
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
    uiElement['color'] = uiElement[title]!['color'];
    uiElement['icon'] = uiElement[title]!['icon'];
    return super.listWidget(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(children: [
            Text(
              title.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 5),
            if (reason.isNotEmpty)
              Text(
                "| $reason",
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ]),
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
      {
        '-': '-',
        'Requested Date': ddmmyyyy(dateTime!),
        'Requested Time': timeFrom(dateTime!)
      },
    );
  }
}
