import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/requests/hostel/change_room_request.dart';
import 'package:hustle_stay/models/requests/hostel/swap_room_request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/hostel/rooms/complete_details_screen.dart';
import 'package:hustle_stay/screens/requests/attendance/update_room_request.dart';
import 'package:hustle_stay/screens/requests/requests_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class AttendanceRequestScreen extends StatelessWidget {
  static const String routeName = 'AttendanceRequestScreen';
  const AttendanceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: 'Hostel Request',
          style:
              theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            GridTileLogo(
              onTap: () async {
                Navigator.of(context).pop();
              },
              title: 'Hostel',
              icon: Icon(
                requestMainPageElements['Hostel']!['icon'],
                size: 50,
              ),
              color: theme.colorScheme.background,
            ),
            if (currentUser.hostelName == null)
              const Text(
                'Sorry, it seems that you aren\'t assigned a hostel yet. Contact administrator for more info.',
                textAlign: TextAlign.center,
              )
            else if (currentUser.roomName == null)
              const Text(
                'Sorry, it seems that you aren\'t assigned a room yet. Contact administrator for more info.',
                textAlign: TextAlign.center,
              )
            else
              Expanded(
                child: GridView.extent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  children: [
                    GridTileLogo(
                      onTap: () async {
                        await navigatorPush(
                          context,
                          CompleteDetails(
                            hostelName: currentUser.hostelName ?? '',
                            roomName: currentUser.roomName ?? '',
                            showLeaveData: true,
                            user: UserData(
                                email: currentUser.email,
                                address: currentUser.address,
                                imgUrl: currentUser.imgUrl,
                                name: currentUser.name,
                                phoneNumber: currentUser.phoneNumber),
                            roommateData:
                                RoommateData(email: currentUser.email!),
                          ),
                        );
                      },
                      title: 'Add leave',
                      icon: const Icon(
                        Icons.time_to_leave_rounded,
                        size: 50,
                      ),
                      color: Colors.indigoAccent,
                    ),
                    GridTileLogo(
                      onTap: () async {
                        await navigatorPush(context, const UpdateRoom());
                      },
                      title: 'Change Room',
                      icon: Icon(
                        ChangeRoomRequest(
                                requestingUserEmail: currentUser.email!)
                            .uiElement['icon'],
                        size: 50,
                      ),
                      color: ChangeRoomRequest(
                              requestingUserEmail: currentUser.email!)
                          .uiElement['color'],
                    ),
                    GridTileLogo(
                      onTap: () async {
                        await navigatorPush(
                            context,
                            const UpdateRoom(
                              isSwap: true,
                            ));
                      },
                      title: 'Swap Room',
                      icon: Icon(
                        SwapRoomRequest(requestingUserEmail: currentUser.email!)
                            .uiElement['icon'],
                        size: 50,
                      ),
                      color: SwapRoomRequest(
                              requestingUserEmail: currentUser.email!)
                          .uiElement['color'],
                    ),
                    //     GridTileLogo(
                    //       onTap: () {
                    //         navigatorPush(
                    //           context,
                    //           Scaffold(
                    //             appBar: AppBar(),
                    //             body: LeaveWidget(
                    //               hostelName: currentUser.hostelName!,
                    //               roomName: currentUser.roomName!,
                    //               user: currentUser,
                    //               roommateData:
                    //                   RoommateData(email: currentUser.email!),
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //       title: 'Leave Hostel',
                    //       icon: Icon(
                    //         Request.uiElements['Attendance']!['Leave Hostel']
                    //             ['icon'],
                    //         size: 50,
                    //       ),
                    //       color: Request.uiElements['Attendance']!['Leave Hostel']
                    //           ['color'],
                    //     ),
                    //     GridTileLogo(
                    //       onTap: () {},
                    //       title: 'Return to Hostel',
                    //       icon: Icon(
                    //         Request.uiElements['Attendance']!['Return to Hostel']
                    //             ['icon'],
                    //         size: 50,
                    //       ),
                    //       color:
                    //           Request.uiElements['Attendance']!['Return to Hostel']
                    //               ['color'],
                    //     ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
