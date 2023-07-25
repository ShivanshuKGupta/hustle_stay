import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/tools.dart';

class UpdateLeaveRequest extends Request {
  DateTimeRange? dateTimeRange;
  UpdateLeaveRequest({
    required super.requestingUserEmail,
    this.dateTimeRange,
  }) : super(
          type: 'Update_Leave',
          uiElement: {
            'color': Colors.cyanAccent,
            'icon': Icons.update_rounded,
          },
        );

  @override
  Map<String, dynamic> encode() {
    return super.encode()
      ..addAll({
        'dateTimeRange.start': dateTimeRange!.start.millisecondsSinceEpoch,
        'dateTimeRange.end': dateTimeRange!.end.millisecondsSinceEpoch,
      });
  }

  @override
  void load(Map<String, dynamic> data) {
    super.load(data);
    dateTimeRange = DateTimeRange(
        start:
            DateTime.fromMillisecondsSinceEpoch(data['dateTimeRange.start']!),
        end: DateTime.fromMillisecondsSinceEpoch(data['dateTimeRange.end']!));
  }

  @override
  Future<void> onApprove(transaction) async {
    /// TODO: Sani
  }

  @override
  Widget widget(context) {
    return super.listWidget(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(children: [
            Text(
              "${ddmmyyyy(dateTimeRange!.start)} - ${ddmmyyyy(dateTimeRange!.end)}",
              style: Theme.of(context).textTheme.bodySmall,
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
        'Start': ddmmyyyy(dateTimeRange!.start),
        'End': ddmmyyyy(dateTimeRange!.end),
      },
    );
  }
}
