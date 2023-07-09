import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/tools.dart';

class FilteredRecords extends StatefulWidget {
  const FilteredRecords(
      {super.key, required this.text, required this.hostelName});
  final ValueNotifier<String>? text;
  final String hostelName;

  @override
  State<FilteredRecords> createState() => _FilteredRecordsState();
}

class _FilteredRecordsState extends State<FilteredRecords> {
  bool isFound = false;

  @override
  void didUpdateWidget(covariant FilteredRecords oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  String email = '';

  @override
  Widget build(BuildContext context) {
    return isFound
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
              return listData(snapshot.data!);
            },
            future: fetchAttendanceByStudent(email, widget.hostelName),
          )
        : ValueListenableBuilder(
            valueListenable: widget.text!,
            builder: (context, value, child) {
              return FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: circularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                  if (snapshot.data == []) {
                    return const Center(
                      child: Text('No matches found'),
                    );
                  }
                  return Center(
                    child: DropdownMenu(
                      dropdownMenuEntries: snapshot.data!,
                      onSelected: (value) {
                        setState(() {
                          email = value.toString();
                          isFound = true;
                        });
                      },
                    ),
                  );
                },
                future: fetchOptions(widget.hostelName, value),
              );
            },
          );
  }

  Widget listData(List<AttendanceRecord> list) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].date),
          trailing: list[index].status == 'onLeave'
              ? Text(
                  'on leave',
                  style: TextStyle(backgroundColor: Colors.yellow[400]),
                )
              : Icon(list[index].status == 'present'
                  ? Icons.check_box_rounded
                  : Icons.close),
        );
      },
      itemCount: list.length,
    );
  }
}
