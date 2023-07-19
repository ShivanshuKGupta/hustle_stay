import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/screens/hostel/rooms/filter_status_data.dart';
import 'package:hustle_stay/screens/hostel/rooms/range_chart.dart';
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
  bool isRangeChart = false;
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
  ValueNotifier<DateTimeRange?> dateRange = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return widget.email == null
        ? isRangeChart
            ? ValueListenableBuilder(
                valueListenable: dateRange,
                builder: (context, value, child) =>
                    futureBuilderWidget(valueRange: value),
              )
            : ValueListenableBuilder(
                valueListenable: widget.selectedDate!,
                builder: (context, value, child) =>
                    futureBuilderWidget(value: value),
              )
        : futureBuilderWidget();
  }

  Widget futureBuilderWidget({DateTime? value, DateTimeRange? valueRange}) {
    return isRangeChart
        ? FutureBuilder(
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

              return chart(snapshot.data!);
            },
            future: getHostelRangeAttendanceStatistics(
                widget.hostelName, valueRange!),
          )
        : FutureBuilder(
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
        Wrap(
          children: [
            if (widget.email == null)
              Checkbox(
                  value: isRangeChart,
                  onChanged: (value) {
                    if (dateRange.value != null) {
                      setState(() {
                        isRangeChart = !isRangeChart;
                      });
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Select Date Range first')));
                    }
                  }),
            if (widget.email == null)
              IconButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023, 01, 01),
                        lastDate: DateTime.now());
                    if (picked != null) {
                      dateRange.value = picked;
                    }
                  },
                  icon: const Icon(Icons.edit_calendar_outlined)),
            if (!isRangeChart)
              DropdownMenu(
                dropdownMenuEntries: chartOptions,
                initialSelection: chartType,
                onSelected: (value) {
                  setState(() {
                    chartType = value;
                  });
                },
              ),
          ],
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
                        onPointTap: (pointInteractionDetails) async {
                          await getHostelRangeAttendanceStatistics(
                              widget.hostelName,
                              DateTimeRange(
                                  start: DateTime(2023, 06, 25),
                                  end: DateTime.now()));
                        }),
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

  Widget chart(Map<String, Map<String, int>> data) {
    List<DataPoint> chartData = convertData(data);
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            children: [
              Checkbox(
                  value: isRangeChart,
                  onChanged: (value) {
                    if (dateRange.value != null) {
                      setState(() {
                        isRangeChart = !isRangeChart;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Select Date Range first')));
                    }
                  }),
              IconButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023, 01, 01),
                        lastDate: DateTime.now());
                    if (picked != null) {
                      dateRange.value = picked;
                    }
                  },
                  icon: const Icon(Icons.edit_calendar_outlined)),
              if (!isRangeChart)
                DropdownMenu(
                  dropdownMenuEntries: chartOptions,
                  initialSelection: chartType,
                  onSelected: (value) {
                    setState(() {
                      chartType = value;
                    });
                  },
                ),
            ],
          ),
          SfCartesianChart(
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
          ),
        ],
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
