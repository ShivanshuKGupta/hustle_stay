import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RangeStatistics extends StatefulWidget {
  const RangeStatistics({super.key, required this.hostelName});
  final String hostelName;

  @override
  State<RangeStatistics> createState() => _RangeStatisticsState();
}

List<DataPoint> convertData(Map<String, Map<String, int>> data) {
  List<DataPoint> convertedData = [];

  data.forEach((date, statuses) {
    statuses.forEach((status, count) {
      List<String> dateComponents = date.split('-');

      int year = int.parse(dateComponents[0]);
      int month = int.parse(dateComponents[1]);
      int day = int.parse(dateComponents[2]);
      convertedData.add(DataPoint(
          date: DateTime(year, month, day), status: status, count: count));
    });
  });

  return convertedData;
}

class DataPoint {
  final DateTime date;
  final String status;
  final int count;

  DataPoint({required this.date, required this.status, required this.count});
}

class _RangeStatisticsState extends State<RangeStatistics> {
  // final List<DataPoint> chartData = convertData(data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Line Chart'),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const Center(
                child: Text('loading...'),
              );
            }
            return chart(snapshot.data!);
          },
          future: getHostelRangeAttendanceStatistics(
              widget.hostelName,
              DateTimeRange(
                  start: DateTime(2023, 06, 15), end: DateTime.now())),
        ));
  }

  Widget chart(Map<String, Map<String, int>> data) {
    List<DataPoint> chartData = convertData(data);
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: DateTimeAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        isVisible: true,
        associatedAxisName: 'Axis Name',
        interval: 1,
        name: 'Name',
        title: AxisTitle(text: 'Date'),
        enableAutoIntervalOnZooming: true,
      ),
      series: _getSeries(chartData),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableSelectionZooming: true,
        enableMouseWheelZooming: true,
        enableDoubleTapZooming: true,
      ),
      legend: const Legend(
        isVisible: true,
        isResponsive: true,
        alignment: ChartAlignment.center,
        orientation: LegendItemOrientation.horizontal,
        position: LegendPosition.bottom,
        width: "100%",
        overflowMode: LegendItemOverflowMode.wrap,
      ),
    );
  }

  List<LineSeries<DataPoint, DateTime>> _getSeries(List<DataPoint> chartData) {
    List<LineSeries<DataPoint, DateTime>> series = [];

    // Get unique status values
    Set<String> statusSet = chartData.map((data) => data.status).toSet();

    // Create a separate line series for each status
    statusSet.forEach((status) {
      Color lineColor;
      switch (status) {
        case 'present':
          lineColor = Colors.green;
          break;
        case 'absent':
          lineColor = Colors.red;
          break;
        case 'onLeave':
          lineColor = Colors.cyan;
          break;
        case 'onInternship':
          lineColor = Colors.orange;
          break;
        default:
          lineColor = Colors.yellow;
          break;
      }
      series.add(LineSeries<DataPoint, DateTime>(
        dataSource: chartData.where((data) => data.status == status).toList(),
        xValueMapper: (DataPoint data, _) => data.date,
        yValueMapper: (DataPoint data, _) => data.count,
        color: lineColor,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        enableTooltip: true,
        legendItemText: status,
      ));
    });

    return series;
  }
}
