import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';

class AttendancePieChart extends StatefulWidget {
  const AttendancePieChart(
      {super.key,
      required this.email,
      required this.hostelName,
      required this.roomName});
  final String email;
  final String hostelName;
  final String roomName;

  @override
  State<AttendancePieChart> createState() => _AttendancePieChartState();
}

class _AttendancePieChartState extends State<AttendancePieChart> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    attendanceData();
  }

  double present = 0;
  double absent = 0;
  double leave = 0;
  double internship = 0;
  List<ChartData>? chartdata;
  Future<void> attendanceData() async {
    Map<String, double> adata = await getAttendanceStatistics(
        widget.email, widget.hostelName, widget.roomName);
    double sum = adata['present']! +
        adata['absent']! +
        adata['internship']! +
        adata['leave']!;
    setState(() {
      present = adata['present']! / sum * 100;
      leave = adata['leave']! / sum * 100;
      internship = adata['internship']! / sum * 100;
      absent = adata['absent']! / sum * 100;
      print(present);
      print(absent);

      chartdata = [
        ChartData(
            'Present', present, charts.MaterialPalette.green.shadeDefault),
        ChartData('Absent', absent, charts.MaterialPalette.red.shadeDefault),
        ChartData('Leave', leave, charts.MaterialPalette.yellow.shadeDefault),
        ChartData(
            'Internship', internship, charts.MaterialPalette.cyan.shadeDefault),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return chartdata == null
        ? Container()
        : charts.PieChart(
            [
              charts.Series<ChartData, String>(
                id: 'attendanceData',
                data: chartdata!,
                domainFn: (ChartData chartData, _) => chartData.category,
                measureFn: (ChartData chartData, _) => chartData.value,
                colorFn: (ChartData chartData, _) => chartData.color,
              )
            ],
            animate: true,
          );
  }
}
