import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
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
  List<ChartData>? chartdata;

  void onClickNavigation(String category) {
    debugPrint(category);
  }

  Map<String, double> data = {};
  int total = 0;
  int selectedCategory = -1;

  @override
  void initState() {
    super.initState();
    attendanceData();
  }

  @override
  void didUpdateWidget(covariant AttendancePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    attendanceData();
  }

  Future<void> attendanceData() async {
    Map<String, double> adata = {};
    if (widget.email != null) {
      adata = await getAttendanceStatistics(
          widget.email!, widget.hostelName, widget.roomName!);
    } else {
      adata = await getHostelAttendanceStatistics(
          widget.hostelName, widget.selectedDate!.value);
    }
    double sum = adata['present']! +
        adata['absent']! +
        adata['internship']! +
        adata['leave']!;

    setState(() {
      data = adata;
      total = sum.toInt();
      double present = adata['present']! / sum * 100;
      double leave = adata['leave']! / sum * 100;
      double internship = adata['internship']! / sum * 100;
      double absent = adata['absent']! / sum * 100;

      chartdata = [
        ChartData('Present', present, Colors.green),
        ChartData('Absent', absent, Colors.red),
        ChartData('Leave', leave, Colors.yellow),
        ChartData('Internship', internship, Colors.cyan),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chartdata == null) {
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
              ),
              const Text('Loading...')
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: chartdata!,
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                selectionBehavior: SelectionBehavior(enable: true),
                onPointTap: (pointInteractionDetails) {
                  onClickNavigation(
                      chartdata![pointInteractionDetails.pointIndex!].category);
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
            data['present']!.toInt().toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Absent'),
          leading: const Icon(Icons.cancel_outlined),
          trailing: Text(
            data['absent']!.toInt().toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Leave'),
          leading: const Icon(Icons.trip_origin_sharp),
          trailing: Text(
            data['leave']!.toInt().toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Internship'),
          leading: const Icon(Icons.work_history),
          trailing: Text(
            data['internship']!.toInt().toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ListTile(
          title: const Text('Total'),
          leading: const Icon(Icons.all_inbox),
          trailing: Text(
            total.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        )
      ],
    );
  }
}
