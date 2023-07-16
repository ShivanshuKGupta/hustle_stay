import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/pair.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Stats extends StatefulWidget {
  final List<ComplaintData> complaints;
  final String groupBy;
  const Stats({super.key, required this.complaints, required this.groupBy});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  /// Number of Complaints vs Date
  Map get createdData {
    return processData(
      list: widget.complaints,
      keyBuilder: (complaint) {
        final createdAt = DateTime.fromMillisecondsSinceEpoch(complaint.id);
        return DateTime(createdAt.year, createdAt.month, createdAt.day);
      },
      valueBuilder: (complaint, previousValue) => (previousValue ?? 0) + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = createdData;
    return ListView(
      children: [
        SfCartesianChart(
          title: ChartTitle(text: 'No of complaints vs date'),
          tooltipBehavior: TooltipBehavior(enable: true),
          legend: const Legend(
            isVisible: true,
            isResponsive: true,
            alignment: ChartAlignment.center,
            orientation: LegendItemOrientation.horizontal,
            position: LegendPosition.top,
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
          onZooming: (zoomingArgs) {
            // showMsg(context, 'Show a preview page');
          },
          // primaryYAxis: NumericAxis(title: AxisTitle(text: 'No of complaints')),
          series: <LineSeries<pair, DateTime>>[
            LineSeries<pair, DateTime>(
              name: 'Complaints Count',
              dataSource: <pair>[
                ...data.entries.map((entry) => pair(entry.key, entry.value)),
              ],
              xValueMapper: (pair sales, _) => sales.first,
              yValueMapper: (pair sales, _) => sales.second,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              enableTooltip: true,
              legendItemText: 'Number of Complaints',
            )
          ],
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true,
            enableDoubleTapZooming: true,
            enablePinching: true,
            enableSelectionZooming: true,
          ),
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
