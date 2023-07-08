import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/screens/hostel/rooms/filter_status_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    if (widget.email == null && widget.selectedDate != null) {
      if (category == 'Leave') {
        category = 'onLeave';
      } else {
        category = category.toLowerCase();
      }
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
    }
  }

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
        adata['leave']!;

    double present = adata['present']! / sum * 100;
    double leave = adata['leave']! / sum * 100;
    double internship = adata['internship']! / sum * 100;
    double absent = adata['absent']! / sum * 100;

    List<ChartData> chartdata = [
      ChartData(
          'Present', double.parse(present.toStringAsFixed(2)), Colors.green),
      ChartData('Absent', double.parse(absent.toStringAsFixed(2)), Colors.red),
      ChartData('Leave', double.parse(leave.toStringAsFixed(2)), Colors.yellow),
      ChartData('Internship', double.parse(internship.toStringAsFixed(2)),
          Colors.cyan),
    ];

    return chartdata;
  }

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
                List<ChartData> chartData = attendanceData(snapshot.data!);
                return pieChartWidget(snapshot.data!, chartData);
              },
              future: widget.email == null && value != null
                  ? getHostelAttendanceStatistics(widget.hostelName, value)
                  : getAttendanceStatistics(
                      widget.email!, widget.hostelName, widget.roomName!));
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
        List<ChartData> chartData = attendanceData(snapshot.data!);
        return pieChartWidget(snapshot.data!, chartData);
      },
      future: widget.email == null && value != null
          ? getHostelAttendanceStatistics(widget.hostelName, value,
              source: Source.cache)
          : getAttendanceStatistics(
              widget.email!, widget.hostelName, widget.roomName!,
              source: Source.cache),
    );
  }

  Widget pieChartWidget(Map<String, double> data, List<ChartData> chartdata) {
    return Column(
      children: [
        Expanded(
          child: SfCircularChart(
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
                      chartdata[pointInteractionDetails.pointIndex!].category);
                },
              ),
            ],
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
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
          title: const Text('Total'),
          leading: const Icon(Icons.all_inbox),
          trailing: Text(
            (data['present']! +
                    data['absent']! +
                    data['internship']! +
                    data['leave']!)
                .toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        )
      ],
    );
  }
}
