import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/screens/hostel/rooms/profile_view_screen.dart';
import 'package:hustle_stay/screens/hostel/rooms/user_statistics.dart';
import 'package:hustle_stay/tools.dart';

class FilteredRecords extends StatefulWidget {
  const FilteredRecords({super.key, required this.hostelName});
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
        isFound
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
            : isEmail == null
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
                      return FutureBuilder(
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
                          if (snapshot.data == []) {
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
      child: ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => UserStatistics(
                    data: list[index], hostelName: widget.hostelName),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ListTile(
                leading: CircleAvatar(
                    radius: 50,
                    child: ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: list[index]['imageUrl'] == null
                            ? null
                            : CachedNetworkImage(
                                imageUrl: list[index]['imageUrl']!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    )),
                title: Text(list[index]['name']!),
                trailing: Text(list[index]['email']!),
              ),
            ),
          );
        },
        itemCount: list.length,
      ),
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
