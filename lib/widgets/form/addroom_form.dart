import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddRoomWid extends ConsumerStatefulWidget {
  AddRoomWid({super.key, required this.hostelName});
  String hostelName;

  @override
  ConsumerState<AddRoomWid> createState() => _AddRoomWidState();
}

class _AddRoomWidState extends ConsumerState<AddRoomWid> {
  final storage = FirebaseFirestore.instance;
  // final _formKey = GlobalKey<FormState>();
  int currentRoomNumber = 0;
  String roomName = "";
  var capacity = 0;
  var numOfRooms = 0;
  bool isRunning = false;
  void addRoom(GlobalKey<FormState> formkey) async {
    if (!formkey.currentState!.validate()) {
      return;
    }
    print('hi');
    formkey.currentState!.save();
    try {
      final loc = storage.collection('hostels').doc(widget.hostelName);

      await loc.collection('Rooms').doc(roomName).set({
        'roomName': roomName,
        'capacity': capacity,
        'numRoommates': 0,
      });
      await loc.update({'numberOfRooms': FieldValue.increment(1)});
      setState(() {
        currentRoomNumber += 1;
        roomName = "";
        capacity = 0;
        isRunning = false;
      });
    } catch (e) {
      print(e);
    }
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
                hintText: "Enter number of rooms to be added",
              ),
              onChanged: (value) {
                setState(() {
                  numOfRooms = int.parse(value);
                });
              },
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final _formKey = GlobalKey<FormState>();

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
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                          enabled: index == currentRoomNumber,
                          decoration: InputDecoration(
                            labelText: "Enter Room name",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter room name";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            roomName = value;
                          },
                        ),
                        TextFormField(
                          enabled: currentRoomNumber == index,
                          decoration: InputDecoration(
                            labelText: "Capacity",
                          ),
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
                                    addRoom(_formKey);
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
