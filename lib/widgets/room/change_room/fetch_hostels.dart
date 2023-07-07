import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/hostel/hostels.dart';
import '../../../tools.dart';
import 'fetch_rooms.dart';

class FetchHostelNames extends StatefulWidget {
  FetchHostelNames(
      {super.key,
      required this.isSwap,
      required this.email,
      required this.roomName,
      required this.hostelName});
  bool isSwap;
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
              return HostelDropDown(snapshot.data!);
            },
          );
        }
        return HostelDropDown(snapshot.data!);
      },
    );
  }

  Widget HostelDropDown(List<DropdownMenuItem> list) {
    return Column(
      children: [
        Container(
          child: Wrap(
            children: [
              Text(
                !widget.isSwap ? 'Select new Hostel' : 'Hostel to Swap',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                width: 5,
              ),
              DropdownButton(
                  items: list,
                  value: destHostelName,
                  onChanged: (value) {
                    setState(() {
                      destHostelName = value;
                    });
                  }),
            ],
          ),
        ),
        if (destHostelName != null && destHostelName != "")
          FetchRooms(
              isSwap: widget.isSwap,
              destHostelName: destHostelName!,
              email: widget.email,
              roomName: widget.roomName,
              hostelName: widget.hostelName)
      ],
    );
  }
}
