import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/pair.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Stats extends StatefulWidget {
  final List<ComplaintData> complaints;
  final String groupBy;
  final String interval;
  final Map<String, UserData> users;
  const Stats({
    super.key,
    required this.complaints,
    required this.groupBy,
    required this.users,
    required this.interval,
  });

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  late Map<String, UserData> complainees;
  late Map<String, List<ComplaintData>> groupedComplaints;

  @override
  void initState() {
    super.initState();
    complainees = {};
    widget.users.forEach((key, value) {
      if (value.readonly.type != 'student') {
        complainees[key] = value;
      }
    });
  }

  /// Number of Complaints vs Date
  Map<String, Map<DateTime, int>> get createdData {
    Map<String, Map<DateTime, int>> data = {};
    groupedComplaints.forEach((key, value) {
      data[key] = processData<ComplaintData, DateTime, int>(
        list: value,
        keyBuilder: (complaint) {
          final createdAt = DateTime.fromMillisecondsSinceEpoch(complaint.id);
          return DateTime(
              createdAt.year,
              widget.interval == 'Day' || widget.interval == 'Month'
                  ? createdAt.month
                  : 0,
              widget.interval == 'Day' ? createdAt.day : 1);
        },
        valueBuilder: (complaint, previousValue) => (previousValue ?? 0) + 1,
      );
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    groupedComplaints = groupComplaints(
        users: widget.users,
        complainees: complainees,
        complaints: widget.complaints,
        groupBy: widget.groupBy);
    final data = createdData;
    return ListView(
      children: [
        SfCartesianChart(
          title: ChartTitle(text: 'No of complaints vs date'),
          tooltipBehavior: TooltipBehavior(enable: true),
          onDataLabelTapped: (onTapArgs) {
            // TODO: show the complaints this data label represents
          },
          legend: const Legend(
            isVisible: true,
            isResponsive: true,
            alignment: ChartAlignment.center,
            orientation: LegendItemOrientation.horizontal,
            position: LegendPosition.bottom,
            width: "100%",
            overflowMode: LegendItemOverflowMode.wrap,
          ),
          primaryXAxis: DateTimeAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            isVisible: true,
            associatedAxisName: 'Axis Name',
            interval: 1,
            name: 'Name',
            title: AxisTitle(text: 'Date'),
            enableAutoIntervalOnZooming: true,
          ),
          // primaryYAxis: NumericAxis(title: AxisTitle(text: 'No of complaints')),
          series: <LineSeries<pair, DateTime>>[
            ...data.entries.map(
              (e) => LineSeries<pair, DateTime>(
                name: e.key,
                dataSource: <pair>[
                  ...e.value.entries
                      .map((entry) => pair(entry.key, entry.value)),
                ],
                xValueMapper: (pair sales, _) => sales.first,
                yValueMapper: (pair sales, _) => sales.second,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                enableTooltip: true,
                legendItemText: e.key,
              ),
            ),
          ],
          // zoomPanBehavior: ZoomPanBehavior(
          //   enablePanning: true,
          //   enableDoubleTapZooming: true,
          //   enablePinching: true,
          //   enableSelectionZooming: true,
          // ),
        ),
      ],
    );
  }
}

Map<Key, Value> processData<RawDataType, Key, Value>({
  required Iterable<RawDataType> list,
  required Key Function(RawDataType element) keyBuilder,
  required Value Function(RawDataType element, Value? previousValue)
      valueBuilder,
}) {
  final Map<Key, Value> data = {};
  for (var element in list) {
    final Key key = keyBuilder(element);
    data[key] = valueBuilder(element, data[key]);
  }
  return data;
}

Map<String, List<ComplaintData>> groupComplaints({
  required Map<String, UserData> users,
  required Map<String, UserData> complainees,
  required Iterable<ComplaintData> complaints,
  required String groupBy,
}) {
  Map<String, List<ComplaintData>> ans = {};
  if (groupBy == 'None') {
    ans = {'Total Complaints': complaints.toList()};
  } else {
    //  'None',
    //  'Hostel',
    //  'Category',
    //  'Scope',
    //  'Complainant',
    //  'Complainee'
    for (final complaint in complaints) {
      String key = '';
      switch (groupBy) {
        case 'Category':
          key = complaint.category ?? 'Other';
          break;
        case 'Scope':
          key = complaint.scope.name;
          break;
        case 'Hostel':
          key = users[complaint.from]!.readonly.hostelName ?? "No Hostel";
          break;
        case 'Complainant':
          key = complaint.from;
          break;
        case 'Complainee':
          for (var element in complaint.to) {
            key = element;
            if (ans[key] == null) ans[key] = [];
            ans[key]!.add(complaint);
          }
          continue;
        default:
          throw "Unidentified grouping criteria: '$groupBy'";
      }
      if (ans[key] == null) ans[key] = [];
      ans[key]!.add(complaint);
    }
  }
  return ans;
}
