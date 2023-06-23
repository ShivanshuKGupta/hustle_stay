import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/room/change_room/change_room.dart';

import '../tools.dart';

class ProfileViewScreen extends StatefulWidget {
  ProfileViewScreen(
      {super.key,
      required this.email,
      required this.hostelName,
      required this.roomName,
      required this.userName});
  String hostelName;
  String email;
  String roomName;
  String userName;

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
      value: 'Change Hostel/Room',
      child: Text('Change Hostel/Room'),
    ),
    DropdownMenuItem(
      value: "Swap Hostel/Room",
      child: Text("Swap Hostel/Room"),
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: shaderText(
          context,
          title: '${widget.userName}\'s Profile',
        )),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  FutureBuilder(
                    future: fetchUserData(widget.email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: circularProgressIndicator(
                            height: null,
                            width: null,
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text('No records exist'),
                        );
                      }
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: null,
                                ),
                              ),
                              Text(
                                widget.email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const Divider(),
                              Text("Name: ${snapshot.data!.name}"),
                              Text("${snapshot.data!.phoneNumber}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Column(
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
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Text(
                                  'Choose your option',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(
                                  width: 5,
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
                          if (dropdownVal != null &&
                              dropdownVal == 'Change Hostel/Room')
                            ChangeRoomWidget(
                                isSwap: false,
                                email: widget.email,
                                roomName: widget.roomName,
                                hostelName: widget.hostelName),
                          if (dropdownVal != null &&
                              dropdownVal == "Swap Hostel/Room")
                            ChangeRoomWidget(
                                isSwap: true,
                                email: widget.email,
                                roomName: widget.roomName,
                                hostelName: widget.hostelName),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ));
  }
}
