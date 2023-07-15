import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/pair.dart';
import 'package:hustle_stay/tools.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Stats extends StatelessWidget {
  final List<ComplaintData> complaints;
  const Stats({super.key, required this.complaints});

  /// Number of Complaints vs Date
  Map get createdData {
    return processData(
      list: complaints,
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
          onAxisLabelTapped: (args) {
            showMsg(context, "${args.axisName}");
          },
          onDataLabelTapped: (onTapArgs) {
            showMsg(context, onTapArgs.text);
          },
          tooltipBehavior: TooltipBehavior(enable: true),
          enableAxisAnimation: true,
          legend: const Legend(
            isVisible: true,
            isResponsive: true,
            alignment: ChartAlignment.center,
            orientation: LegendItemOrientation.horizontal,
            position: LegendPosition.bottom,
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
    final Value value = valueBuilder(element, data[key]);
    data[key] = value;
  }
  return data;
}
