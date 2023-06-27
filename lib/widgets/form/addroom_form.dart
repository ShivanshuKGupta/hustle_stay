import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';

class AddRoomWid extends ConsumerStatefulWidget {
  AddRoomWid({super.key, required this.hostelName});
  String hostelName;

  @override
  ConsumerState<AddRoomWid> createState() => _AddRoomWidState();
}

class _AddRoomWidState extends ConsumerState<AddRoomWid> {
  List<GlobalKey<FormState>> _formKeyList = [];
  final storage = FirebaseFirestore.instance;
  // final _formKeyList[index] = GlobalKey<FormState>();
  int currentRoomNumber = 0;
  String roomName = "";
  var capacity = 0;
  var numOfRooms = 0;
  bool isRunning = false;
  void addRoom(int index) async {
    if (_formKeyList[index].currentState!.validate()) {
      _formKeyList[index].currentState!.save();
      if (await isRoomExists(widget.hostelName, roomName)) {
        _formKeyList[index].currentState!.reset();
        setState(() {
          isRunning = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Room with same name already exists in ${widget.hostelName}. Try again with other hostel name.'),
        ));
        return;
      }
      try {
        final loc = storage.collection('hostels').doc(widget.hostelName);

        await loc.collection('Rooms').doc(roomName).set({
          'roomName': roomName,
          'capacity': capacity,
          'numRoommates': 0,
        });
        await loc.update({'numberOfRooms': FieldValue.increment(1)});
        if (currentRoomNumber < numOfRooms - 1) {
          setState(() {
            currentRoomNumber += 1;
            roomName = "";
            capacity = 0;
            isRunning = false;
          });
          return;
        }
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            // Text("hi"),
            TextField(
              decoration: InputDecoration(
                label: Text("Enter number of rooms to be added"),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  numOfRooms = int.parse(value);
                  for (int i = 0; i < numOfRooms; i++) {
                    _formKeyList.add(GlobalKey<FormState>());
                  }
                });
              },
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Card(
                    child: Column(
                  children: [
                    Text(
                      "Room ${index + 1}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: _formKeyList[index],
                      child: Column(children: [
                        TextFormField(
                          enabled: index == currentRoomNumber,
                          decoration: InputDecoration(
                            labelText: "Enter Room name",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Room name is required";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            roomName = value.toUpperCase();
                          },
                        ),
                        TextFormField(
                          enabled: currentRoomNumber == index,
                          decoration: InputDecoration(
                            labelText: "Capacity",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Capacity is mandator field";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            capacity = int.parse(value);
                          },
                        ),
                        if (currentRoomNumber == index)
                          isRunning
                              ? CircularProgressIndicator()
                              : TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isRunning = true;
                                    });
                                    addRoom(index);
                                  },
                                  icon: Icon(Icons.add_circle_outline),
                                  label: Text("Add Room"))
                      ]),
                    )
                  ],
                ));
              },
              itemCount: numOfRooms,
              shrinkWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
