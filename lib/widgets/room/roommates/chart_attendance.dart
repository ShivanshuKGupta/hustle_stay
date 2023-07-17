import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/screens/hostel/rooms/filter_status_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../screens/hostel/rooms/attendance_stats_student.dart';

class AttendancePieChart extends StatefulWidget {
  const AttendancePieChart({
    Key? key,
    this.email,
    required this.hostelName,
    this.roomName,
    this.selectedDate,
  }) : super(key: key);

  final String? email;
  final String hostelName;
  final String? roomName;
  final ValueNotifier<DateTime>? selectedDate;

  @override
  State<AttendancePieChart> createState() => _AttendancePieChartState();
}

class _AttendancePieChartState extends State<AttendancePieChart> {
  void onClickNavigation(String category) {
    switch (category) {
      case 'Leave':
        category = 'onLeave';
        break;
      case 'Late':
        category = 'presentLate';
        break;
      case 'Internship':
        category = "onInternship";
        break;
      default:
        category = category.toLowerCase();
    }
    if (widget.email == null && widget.selectedDate != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => FilterStudents(
                  status: category,
                  hostelName: widget.hostelName,
                  date: widget.selectedDate!.value)))
          .then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AttendanceStudent(
          hostelName: widget.hostelName,
          email: widget.email!,
          status: category,
        ),
      ));
    }
  }

  String chartType = 'pieChart';

  bool isRunning = false;
  int total = 0;

  @override
  void didUpdateWidget(covariant AttendancePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  List<ChartData> attendanceData(Map<String, double> adata) {
    double sum = adata['present']! +
        adata['absent']! +
        adata['internship']! +
        adata['leave']! +
        adata['presentLate']!;

    double present = chartType == 'barChart'
        ? adata['present']!
        : adata['present']! / adata['total']! * 100;
    double leave = chartType == 'barChart'
        ? adata['leave']!
        : adata['leave']! / adata['total']! * 100;
    double internship = chartType == 'barChart'
        ? adata['internship']!
        : adata['internship']! / adata['total']! * 100;
    double absent = chartType == 'barChart'
        ? adata['absent']!
        : adata['absent']! / adata['total']! * 100;
    double presentLate = chartType == 'barChart'
        ? adata['presentLate']!
        : adata['presentLate']! / adata['total']! * 100;
    double noStatus = chartType == 'barChart'
        ? adata['total']! - sum
        : (adata['total']! - sum) / adata['total']! * 100;

    List<ChartData> chartdata = [
      ChartData(
          'Present', double.parse(present.toStringAsFixed(2)), Colors.green),
      ChartData('Absent', double.parse(absent.toStringAsFixed(2)), Colors.red),
      ChartData('Leave', double.parse(leave.toStringAsFixed(2)), Colors.cyan),
      ChartData('Internship', double.parse(internship.toStringAsFixed(2)),
          Colors.orange),
      ChartData(
          'Late', double.parse(presentLate.toStringAsFixed(2)), Colors.yellow),
      ChartData('Not Taken', double.parse(noStatus.toStringAsFixed(2)),
          Colors.blueGrey),
    ];

    return chartdata;
  }

  List<DropdownMenuEntry> chartOptions = [
    const DropdownMenuEntry(value: 'barChart', label: 'Bar Chart'),
    const DropdownMenuEntry(value: 'pieChart', label: 'Pie Chart'),
  ];

  @override
  Widget build(BuildContext context) {
    return widget.email == null
        ? ValueListenableBuilder(
            valueListenable: widget.selectedDate!,
            builder: (context, value, child) =>
                futureBuilderWidget(value: value),
          )
        : futureBuilderWidget();
  }

  Widget futureBuilderWidget({DateTime? value}) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimateIcon(
                    onTap: () {},
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.loading1,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text('Loading...')
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData && snapshot.error != null) {
          return Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimateIcon(
                    onTap: () {},
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.error,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Text('No data available')
                ],
              ),
            ),
          );
        }

        return pieChartWidget(snapshot.data!);
      },
      future: widget.email == null && value != null
          ? getHostelAttendanceStatistics(widget.hostelName, value)
          : getAttendanceStatistics(widget.email!, widget.hostelName),
    );
  }

  Widget pieChartWidget(Map<String, double> data) {
    List<ChartData> chartdata = attendanceData(data);

    return Column(
      children: [
        DropdownMenu(
          dropdownMenuEntries: chartOptions,
          initialSelection: chartType,
          onSelected: (value) {
            setState(() {
              chartType = value;
            });
          },
        ),
        Expanded(
          child: chartType == 'pieChart'
              ? SfCircularChart(
                  series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                      dataSource: chartdata,
                      pointColorMapper: (ChartData data, _) => data.color,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                      ),
                      selectionBehavior: SelectionBehavior(enable: true),
                      onPointLongPress: (pointInteractionDetails) {
                        onClickNavigation(
                            chartdata[pointInteractionDetails.pointIndex!]
                                .category);
                      },
                    ),
                  ],
                  legend: const Legend(
                    isVisible: true,
                    isResponsive: true,
                    position: LegendPosition.bottom,
                    orientation: LegendItemOrientation.horizontal,
                    alignment: ChartAlignment.center,
                    width: "100%",
                    overflowMode: LegendItemOverflowMode.scroll,
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    textStyle: const TextStyle(fontSize: 12),
                    format: 'point.x: point.y%',
                  ),
                  palette: const <Color>[
                    Colors.green,
                    Colors.red,
                    Colors.yellow,
                    Colors.cyan,
                  ],
                  enableMultiSelection: false,
                )
              : SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  series: <BarSeries<ChartData, String>>[
                    BarSeries<ChartData, String>(
                      dataSource: chartdata,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value,
                      pointColorMapper: (ChartData data, _) => data.color,
                      onPointLongPress: (pointInteractionDetails) {
                        onClickNavigation(
                            chartdata[pointInteractionDetails.pointIndex!]
                                .category);
                      },
                    ),
                  ],
                ),
        ),
        const Divider(),
        ListTile(
          title: const Text('Present'),
          leading: const Icon(Icons.check_circle_outline),
          trailing: Text(
            data['present']!.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Absent'),
          leading: const Icon(Icons.cancel_outlined),
          trailing: Text(
            data['absent']!.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Leave'),
          leading: const Icon(Icons.trip_origin_sharp),
          trailing: Text(
            data['leave']!.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Internship'),
          leading: const Icon(Icons.work_history),
          trailing: Text(
            data['internship']!.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Late'),
          leading: const Icon(Icons.all_inbox),
          trailing: Text(
            (data['presentLate']!).toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Not Taken Yet'),
          leading: const Icon(Icons.all_inbox),
          trailing: Text(
            ((data['total']! -
                    (data['present']! +
                        data['absent']! +
                        data['internship']! +
                        data['leave']! +
                        data['presentLate']!)))
                .toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Total'),
          leading: const Icon(Icons.all_inbox),
          trailing: Text(
            (data['total']!).toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        )
      ],
    );
  }
}
