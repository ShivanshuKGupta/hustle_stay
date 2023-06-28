import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/room/change_room/change_room.dart';

import '../../../tools.dart';

class ProfileViewScreen extends StatefulWidget {
  ProfileViewScreen(
      {super.key,
      required this.hostelName,
      required this.roomName,
      required this.user});
  String hostelName;
  String roomName;
  UserData user;

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  var destHostelName = "";
  var destRoomName = "";
  bool isRunning = false;
  String? dropdownVal;
  List<DropdownMenuItem> operation = [
    DropdownMenuItem(
      value: 'Change Room',
      child: Text(
        'Change Room',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10),
      ),
    ),
    DropdownMenuItem(
      value: "Swap Room",
      child: Text(
        "Swap Room",
        style: TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    )
  ];
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            title: shaderText(
          context,
          title: '${widget.user.name}\'s Profile',
        )),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(widthScreen * 0.03),
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: CircleAvatar(
                              radius: 50,
                              child: ClipOval(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: widget.user.imgUrl == null
                                      ? null
                                      : CachedNetworkImage(
                                          imageUrl: widget.user.imgUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              )),
                        ),
                        Text(
                          widget.user.email!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const Divider(),
                        Text("Name: ${widget.user.name}"),
                        Text("${widget.user.phoneNumber}"),
                      ],
                    ),
                  ),
                  Divider(),
                  Column(
                    children: [
                      Center(
                          child: Text(
                        'Edit Hostel/Room',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              'Choose your option',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(
                              width: widthScreen * 0.05,
                            ),
                            DropdownButton(
                                items: operation,
                                value: dropdownVal,
                                onChanged: (value) {
                                  setState(() {
                                    dropdownVal = value;
                                  });
                                }),
                          ],
                        ),
                      ),
                      if (dropdownVal != null && dropdownVal == 'Change Room')
                        ChangeRoomWidget(
                            isSwap: false,
                            email: widget.user.email!,
                            roomName: widget.roomName,
                            hostelName: widget.hostelName),
                      if (dropdownVal != null && dropdownVal == "Swap Room")
                        ChangeRoomWidget(
                            isSwap: true,
                            email: widget.user.email!,
                            roomName: widget.roomName,
                            hostelName: widget.hostelName),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
