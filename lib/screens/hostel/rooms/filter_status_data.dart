import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/widgets/room/roommates/roommate_data.dart';

class FilterStudents extends StatefulWidget {
  const FilterStudents(
      {super.key,
      required this.status,
      required this.hostelName,
      required this.date});
  final String status;
  final String hostelName;
  final DateTime date;

  @override
  State<FilterStudents> createState() => _FilterStudentsState();
}

class _FilterStudentsState extends State<FilterStudents> {
  
  ValueNotifier<List<RoommateInfo>>? list = ValueNotifier([]);

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Students'),
      ),
      body: FutureBuilder(
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

          list!.value = snapshot.data!;
          return listStudents();
        },
        future:
            getFilteredStudents(widget.status, widget.date, widget.hostelName),
      ),
    );
  }

  Widget listStudents() {
    return ValueListenableBuilder(
      valueListenable: list!,
      builder: (context, value, child) => ListView.builder(
        itemBuilder: (context, index) {
          return RoommateDataWidget(
            roommateData: list!.value[index].roommateData,
            selectedDate: widget.date,
            roomName: list!.value[index].roomName,
            hostelName: widget.hostelName,
            status: widget.status,
            isNeeded: false,
          );
        },
        itemCount: list!.value.length,
      ),
    );
  }
}
