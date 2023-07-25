import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';

import '../../../models/hostel/hostels.dart';
import '../../../models/hostel/rooms/room.dart';
import '../../../models/requests/hostel/change_room_request.dart';
import '../../../models/requests/hostel/swap_room_request.dart';
import '../../../tools.dart';

class UpdateRoomWidget extends StatefulWidget {
  const UpdateRoomWidget(
      {super.key,
      this.hostelName,
      this.roomName,
      this.isSwap = false,
      this.email});
  final String? hostelName;
  final String? roomName;
  final String? email;
  final bool isSwap;

  @override
  State<UpdateRoomWidget> createState() => _UpdateRoomWidgetState();
}

class _UpdateRoomWidgetState extends State<UpdateRoomWidget> {
  ValueNotifier<String> hostelName = ValueNotifier("");
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchHostelNames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: fetchHostelNames(src: Source.cache),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.error != null) {
                return Center(
                  child: circularProgressIndicator(
                    height: null,
                    width: null,
                  ),
                );
              }
              return hostelSelect(snapshot.data!);
            },
          );
        }
        return hostelSelect(snapshot.data!);
      },
    );
  }

  Widget hostelSelect(List<String> hostels) {
    return Column(
      children: [
        SelectOne(
          title: 'Select Destination Hostel',
          allOptions: hostels.toSet(),
          onChange: (chosenOption) {
            hostelName.value = chosenOption;
            return true;
          },
        ),
        ValueListenableBuilder(
            valueListenable: hostelName,
            builder: (context, value, child) {
              return value == ""
                  ? Container()
                  : ValueListenableBuilder(
                      valueListenable: hostelName,
                      builder: (context, value, child) {
                        return FutureBuilder(
                          future: fetchRoomNames(value,
                              roomname: value == widget.hostelName ||
                                      value == currentUser.readonly.hostelName
                                  ? widget.roomName ??
                                      currentUser.readonly.roomName
                                  : null),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData ||
                                snapshot.error != null) {
                              return Center(
                                child: circularProgressIndicator(
                                  height: null,
                                  width: null,
                                ),
                              );
                            }
                            return roomSelect(snapshot.data!);
                          },
                        );
                      },
                    );
            }),
      ],
    );
  }

  ValueNotifier<String> roomName = ValueNotifier("");
  Widget roomSelect(List<String> rooms) {
    return Column(
      children: [
        SelectOne(
          title: 'Select Destination Room',
          allOptions: rooms.toSet(),
          onChange: (chosenOption) {
            roomName.value = chosenOption;
            return true;
          },
        ),
        ValueListenableBuilder(
          valueListenable: roomName,
          builder: (context, value, child) {
            return Column(
              children: [
                if (value != "" && widget.isSwap == false)
                  SingleChildScrollView(
                    child: TextField(
                      decoration:
                          InputDecoration(label: Text('Enter your reason')),
                      maxLines: 5,
                      onChanged: (value) {
                        reason.value = value;
                      },
                    ),
                  ),
                if (value != "" && widget.isSwap == false)
                  ValueListenableBuilder(
                    valueListenable: reason,
                    builder: (context, valueText, child) => ElevatedButton.icon(
                        onPressed: valueText == ''
                            ? () {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Enter reason first!')));
                              }
                            : () async {
                                final request = ChangeRoomRequest(
                                    requestingUserEmail:
                                        widget.email ?? currentUser.email!);
                                request.targetHostel = hostelName.value;
                                request.targetRoomName = roomName.value;

                                request.reason = valueText;
                                await request.update();
                              },
                        icon: Icon(Icons.add_circle_outline_outlined),
                        label: const Text('Submit Request')),
                  ),
                if (value != "" && widget.isSwap)
                  ValueListenableBuilder(
                    valueListenable: roomName,
                    builder: (context, value, child) {
                      return FutureBuilder(
                        future: fetchRoommateNames(hostelName.value, value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData ||
                              snapshot.error != null) {
                            return Center(
                              child: circularProgressIndicator(
                                height: null,
                                width: null,
                              ),
                            );
                          }
                          return roommateSelect(snapshot.data!);
                        },
                      );
                    },
                  )
              ],
            );
          },
        ),
      ],
    );
  }

  ValueNotifier<bool> isRunning = ValueNotifier(false);
  ValueNotifier<String> roommateName = ValueNotifier("");
  ValueNotifier<String> reason = ValueNotifier("");
  Widget roommateSelect(List<String> roommates) {
    return Column(
      children: [
        SelectOne(
          title: 'Select Roommate',
          allOptions: roommates.toSet(),
          onChange: (chosenOption) {
            roommateName.value = chosenOption;
            return true;
          },
        ),
        ValueListenableBuilder(
          valueListenable: roommateName,
          builder: (context, value, child) => Column(
            children: [
              SingleChildScrollView(
                child: TextField(
                  decoration: InputDecoration(label: Text('Enter your reason')),
                  maxLines: 5,
                  onChanged: (value) {
                    reason.value = value;
                  },
                ),
              ),
              if (value != "")
                ValueListenableBuilder(
                  valueListenable: reason,
                  builder: (context, valueText, child) => ElevatedButton.icon(
                      onPressed: valueText == ''
                          ? () {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Enter reason first!')));
                            }
                          : () async {
                              final request = SwapRoomRequest(
                                  requestingUserEmail:
                                      widget.email ?? currentUser.email!);
                              request.targetUserEmail = roommateName.value;
                              request.reason = valueText;
                              await request.update();
                            },
                      icon: Icon(Icons.add_circle_outline_outlined),
                      label: const Text('Submit Request')),
                )
            ],
          ),
        ),
      ],
    );
  }
}
