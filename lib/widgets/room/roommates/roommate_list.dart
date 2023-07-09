import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/room/roommates/roommate_data.dart';

import '../../../models/hostel/rooms/room.dart';

class RoommateWidget extends StatefulWidget {
  const RoommateWidget(
      {super.key,
      required this.roomData,
      required this.selectedDate,
      required this.hostelName});
  final Room roomData;
  final ValueNotifier<DateTime> selectedDate;
  final String hostelName;

  @override
  State<RoommateWidget> createState() => _RoommateWidgetState();
}

class _RoommateWidgetState extends State<RoommateWidget> {
  @override
  Widget build(BuildContext context) {
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
                  return roommateListWidget(snapshot.data!);
                },
                future: fetchRoommates(
                    widget.hostelName, widget.roomData.roomName));
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
          return roommateListWidget(snapshot.data!);
        },
        future: fetchRoommates(widget.hostelName, widget.roomData.roomName));
  }

  Widget roommateListWidget(List<RoommateData> roomMatesData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.roomData.numberOfRoommates,
      itemBuilder: (context, roommateIndex) {
        final roommate = roomMatesData[roommateIndex];

        return ValueListenableBuilder(
            valueListenable: widget.selectedDate,
            builder: (context, value, child) {
              return RoommateDataWidget(
                roomName: widget.roomData.roomName,
                hostelName: widget.hostelName,
                roommateData: roommate,
                selectedDate: widget.selectedDate.value,
              );
            });
      },
    );
  }
}
