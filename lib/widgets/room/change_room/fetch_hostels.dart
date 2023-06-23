import 'package:flutter/material.dart';

import '../../../models/hostels.dart';
import '../../../tools.dart';
import 'fetch_rooms.dart';

class FetchHostelNames extends StatefulWidget {
  FetchHostelNames(
      {super.key,
      required this.email,
      required this.roomName,
      required this.hostelName});
  String email;
  String roomName;
  String hostelName;

  @override
  State<FetchHostelNames> createState() => _FetchHostelNamesState();
}

class _FetchHostelNamesState extends State<FetchHostelNames> {
  String? destHostelName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: fetchHostelNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: circularProgressIndicator(
                  height: null,
                  width: null,
                ),
              );
            }
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Text(
                    'Choose new Hostel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  DropdownButton(
                      items: snapshot.data,
                      value: destHostelName,
                      onChanged: (value) {
                        setState(() {
                          destHostelName = value;
                        });
                      }),
                ],
              ),
            );
          },
        ),
        if (destHostelName != null && destHostelName != "")
          FetchRooms(
              destHostelName: destHostelName!,
              email: widget.email,
              roomName: widget.roomName,
              hostelName: widget.hostelName)
      ],
    );
  }
}
