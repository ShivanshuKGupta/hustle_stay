import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/screens/rooms_screen.dart';

import '../models/hostels.dart';
import '../tools.dart';
import 'add_rooms.dart';
// import 'package:hustle_stay/models/user.dart';

final _firebase = FirebaseAuth.instance;

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  final store = FirebaseFirestore.instance;
  bool isRunning = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchHostels(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: fetchHostels(src: Source.cache),
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
              return HostelList(snapshot.data!);
            },
          );
        }
        return HostelList(snapshot.data!);
      },
    );
  }

  Widget HostelList(List<Hostels> hostelList) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          Hostels hostel = hostelList[index];
          String? imageUrl = hostel.imageUrl;
          return InkWell(
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RoomsScreen(
                        hostelName: hostel.hostelName,
                      )))
            },
            child: Card(
              elevation: 6,
              child: Column(
                children: [
                  Stack(children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    if (!isRunning)
                      IconButton(
                          alignment: Alignment.topLeft,
                          onPressed: () async {
                            setState(() {
                              isRunning = true;
                            });
                            bool resp = await deleteHostel(hostel.hostelName);

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(resp
                                    ? "Deleted Successfully"
                                    : "Deletion failed. Try again later.")));
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ))
                  ]),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hostel.hostelName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${hostel.hostelType} Hostel",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${hostel.numberOfRooms}",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => AddRoom(
                                        hostelName: hostel.hostelName))),
                            icon: Icon(Icons.add),
                            label: Text("Add Room")),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: hostelList.length,
      ),
    );
  }
}
