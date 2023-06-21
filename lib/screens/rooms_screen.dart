import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/room.dart';

import '../tools.dart';

class RoomsScreen extends StatefulWidget {
  RoomsScreen({super.key, required this.hostelName});
  String hostelName;
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final store = FirebaseFirestore.instance;
  int numberOfRooms = 0;
  void getnumRooms() async {
    print(widget.hostelName);
    await store.collection('hostels').doc(widget.hostelName).get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          numberOfRooms = data!['numberOfRooms'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getnumRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: shaderText(context, title: "Rooms"),
        ),
        body: FutureBuilder(
          future: fetchRooms(widget.hostelName),
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
                child: Text('No Rooms added yet!'),
              );
            }
            print(snapshot.data);
            print(snapshot.data![0]);
            return ListView.builder(
              itemCount: numberOfRooms,
              itemBuilder: (context, index) {
                final roomData = snapshot.data![index];
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Expanded(
                    child: Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                title: Text(roomData.roomName),
                                subtitle:
                                    Text("Capacity: ${roomData.capacity}"),
                              )),
                              TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.add),
                                  label: Text("Add Roommates")),
                            ],
                          ),
                          Column(children: [
                            roomData.numberOfRoommates == 0
                                ? Text("No roommates added yet")
                                : Text('Roommates'),
                            // Text('Roommates'),
                            for (int index = 0;
                                index < roomData.numberOfRoommates;
                                index++)
                              ListTile(
                                  title:
                                      Text(roomData.roomMatesData![index].name),
                                  subtitle: Text(
                                    roomData.roomMatesData![index].rollNumber,
                                  )),
                          ])
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
