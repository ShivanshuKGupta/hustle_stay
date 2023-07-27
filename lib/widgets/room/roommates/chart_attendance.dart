import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/screens/hostel/rooms/filter_status_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../screens/hostel/rooms/attendance_stats_student.dart';
import '../../../tools.dart';
import '../../complaints/select_one.dart';

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
  void onClickNavigation(String category, {List<String>? students}) {
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
      print('gere');
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => FilterStudents(
                  status: category,
                  hostelName: widget.hostelName,
                  date: widget.selectedDate!.value,
                  students: students)))
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

  String chartType = 'Pie Chart';
  bool isRunning = false;
  int total = 0;

  @override
  void didUpdateWidget(covariant AttendancePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  List<ChartData> attendanceData(Map<String, dynamic> adata) {
    double sum = adata['present']! +
        adata['absent']! +
        adata['internship']! +
        adata['leave']! +
        adata['presentLate']!;

    double present = chartType == 'Bar Chart'
        ? adata['present']!
        : adata['present']! / adata['total']! * 100;
    double leave = chartType == 'Bar Chart'
        ? adata['leave']!
        : adata['leave']! / adata['total']! * 100;
    double internship = chartType == 'Bar Chart'
        ? adata['internship']!
        : adata['internship']! / adata['total']! * 100;
    double absent = chartType == 'Bar Chart'
        ? adata['absent']!
        : adata['absent']! / adata['total']! * 100;
    double presentLate = chartType == 'Bar Chart'
        ? adata['presentLate']!
        : adata['presentLate']! / adata['total']! * 100;
    double noStatus = chartType == 'Bar Chart'
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

  List<String> chartOptions = [
    'Bar Chart',
    'Pie Chart',
    'Line Chart',
  ];
  ValueNotifier<DateTimeRange?> dateRange = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return widget.email == null
        ? chartType == 'Line Chart'
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
    return chartType == 'Line Chart'
        ? dateRange.value == null
            ? Column(
                children: [
                  SelectOne(
                    title: 'Select Chart Type',
                    allOptions: chartOptions.toSet(),
                    selectedOption: chartType,
                    onChange: (value) {
                      setState(() {
                        chartType = value;
                      });
                      return true;
                    },
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2023, 01, 01),
                          lastDate: DateTime.now());
                      if (picked != null) {
                        dateRange.value = picked;
                      }
                    },
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: Text(dateRange.value == null
                        ? 'Select Date Range'
                        : '${ddmmyyyy(dateRange.value!.start)}-${ddmmyyyy(dateRange.value!.end)}'),
                  )
                ],
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

              return pieBarChartWidget(snapshot.data!);
            },
            future: widget.email == null && value != null
                ? getHostelAttendanceStatistics(widget.hostelName, value)
                : getAttendanceStatistics(widget.email!, widget.hostelName),
          );
  }

  ValueNotifier<bool> isOpen = ValueNotifier(false);
  Widget pieBarChartWidget(Map<String, dynamic> data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final layout = MediaQuery.of(context).orientation;
    List<ChartData> chartdata = attendanceData(data);

    return SingleChildScrollView(
      child: ValueListenableBuilder(
        valueListenable: isOpen,
        builder: (context, value, child) => Column(
          children: [
            SelectOne(
              title: 'Select Chart Type',
              allOptions: widget.email != null
                  ? chartOptions.sublist(0, 2).toSet()
                  : chartOptions.toSet(),
              selectedOption: chartType,
              onChange: (value) {
                setState(() {
                  chartType = value;
                });
                return true;
              },
            ),
            SizedBox(
              height: value
                  ? layout == Orientation.landscape
                      ? screenWidth * 0.3
                      : screenWidth * 0.8
                  : layout == Orientation.landscape
                      ? screenWidth * 0.5
                      : screenWidth,
              child: chartType == 'Pie Chart'
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
                            String cat =
                                chartdata[pointInteractionDetails.pointIndex!]
                                    .category;
                            onClickNavigation(cat,
                                students: cat == 'Not Taken'
                                    ? data['notMarked']
                                    : null);
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
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      primaryYAxis: NumericAxis(
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold)),
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
            StatList(data: data, isOpen: isOpen),
          ],
        ),
      ),
    );
  }

  Widget chart(Map<String, Map<String, int>> data) {
    List<DataPoint> chartData = convertData(data);
    return SingleChildScrollView(
      child: Column(
        children: [
          SelectOne(
            title: 'Select Chart Type',
            allOptions: chartOptions.toSet(),
            selectedOption: chartType,
            onChange: (value) {
              setState(() {
                chartType = value;
              });
              return true;
            },
          ),
          if (chartType == 'Line Chart')
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023, 01, 01),
                    lastDate: DateTime.now());
                if (picked != null) {
                  dateRange.value = picked;
                }
              },
              icon: const Icon(Icons.edit_calendar_outlined),
              label: Text(dateRange.value == null
                  ? 'Select Date Range'
                  : '${ddmmyyyy(dateRange.value!.start)} to ${ddmmyyyy(dateRange.value!.end)}'),
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

class StatList extends StatefulWidget {
  const StatList({super.key, required this.data, required this.isOpen});
  final Map<String, dynamic> data;
  final ValueNotifier<bool> isOpen;

  @override
  State<StatList> createState() => _StatListState();
}

class _StatListState extends State<StatList> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          trailing: IconButton(
              onPressed: () {
                widget.isOpen.value = !widget.isOpen.value;
              },
              icon: widget.isOpen.value
                  ? const Icon(Icons.arrow_drop_up)
                  : const Icon(Icons.arrow_drop_down)),
        ),
        if (widget.isOpen.value)
          Column(
            children: [
              ListTile(
                title: const Text('Present'),
                leading: const Icon(Icons.check_circle_outline),
                trailing: Text(
                  widget.data['present']!.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: const Text('Absent'),
                leading: const Icon(Icons.cancel_outlined),
                trailing: Text(
                  widget.data['absent']!.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: const Text('Leave'),
                leading: const Icon(Icons.trip_origin_sharp),
                trailing: Text(
                  widget.data['leave']!.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: const Text('Internship'),
                leading: const Icon(Icons.work_history),
                trailing: Text(
                  widget.data['internship']!.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: const Text('Late'),
                leading: const Icon(Icons.watch_later),
                trailing: Text(
                  (widget.data['presentLate']!).toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: const Text('Not Taken Yet'),
                leading: const Icon(Icons.hourglass_empty),
                trailing: Text(
                  ((widget.data['total']! -
                          (widget.data['present']! +
                              widget.data['absent']! +
                              widget.data['internship']! +
                              widget.data['leave']! +
                              widget.data['presentLate']!)))
                      .toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: const Text('Total'),
                leading: const Icon(Icons.all_inbox),
                trailing: Text(
                  (widget.data['total']!).toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            ],
          )
      ],
    );
  }
}
