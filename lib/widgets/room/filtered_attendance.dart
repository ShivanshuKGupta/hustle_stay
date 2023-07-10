import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/room/roommates/roommate_data.dart';

class FilteredRecords extends StatefulWidget {
  const FilteredRecords(
      {super.key, required this.hostelName, required this.selectedDate});
  final String hostelName;
  final ValueNotifier<DateTime>? selectedDate;

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

  String email = "";
  bool? isEmail;
  ValueNotifier<String>? textController = ValueNotifier("");

  List<DropdownMenuEntry> listDropDown = const [
    DropdownMenuEntry(value: true, label: 'Email'),
    DropdownMenuEntry(value: false, label: 'Name')
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [
            DropdownMenu(
              dropdownMenuEntries: listDropDown,
              onSelected: (value) {
                setState(() {
                  isEmail = value;
                });
              },
            ),
            TextField(
              enabled: isEmail != null,
              decoration: const InputDecoration(hintText: "Enter here"),
              onChanged: (value) {
                textController!.value = value;
              },
            ),
          ],
        ),
        const Divider(),
        isEmail == null
            ? Text(
                'Please select one of the options first!',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.error),
              )
            : ValueListenableBuilder(
                valueListenable: textController!,
                builder: (context, value, child) {
                  return value == ""
                      ? const Center(
                          child: Text('No data'),
                        )
                      : FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: circularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: Text('No data'),
                              );
                            }
                            if (snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('No matches found'),
                              );
                            }

                            return listOptions(snapshot.data!);
                          },
                          future:
                              fetchOptions(widget.hostelName, value, isEmail!),
                        );
                },
              ),
      ],
    );
  }

  Widget listOptions(List<Map<String, String>> list) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: widget.selectedDate!,
        builder: (context, value, child) => ListView.builder(
          itemBuilder: (context, index) {
            return RoommateDataWidget(
              selectedDate: value,
              hostelName: widget.hostelName,
              email: list[index]['email'],
            );
          },
          itemCount: list.length,
        ),
      ),
    );
  }
}
