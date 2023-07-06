import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';

import '../../models/hostel/hostels.dart';
import '../../tools.dart';
import 'rooms/add_rooms.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Select Hostel"),
      ),
      body: FutureBuilder(
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
      ),
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
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
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
