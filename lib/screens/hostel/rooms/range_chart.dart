// import 'package:flutter/material.dart';
// import 'package:hustle_stay/models/attendance.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class RangeStatistics extends StatefulWidget {
//   const RangeStatistics({super.key, required this.hostelName});
//   final String hostelName;

//   @override
//   State<RangeStatistics> createState() => _RangeStatisticsState();
// }



// class _RangeStatisticsState extends State<RangeStatistics> {
//   // final List<DataPoint> chartData = convertData(data);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Line Chart'),
//         ),
//         body: FutureBuilder(
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting ||
//                 !snapshot.hasData) {
//               return const Center(
//                 child: Text('loading...'),
//               );
//             }
//             return chart(snapshot.data!);
//           },
//           future: getHostelRangeAttendanceStatistics(
//               widget.hostelName,
//               DateTimeRange(
//                   start: DateTime(2023, 06, 15), end: DateTime.now())),
//         ));
//   }

  
// }
