import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';

import '../../../tools.dart';

class RoommateForm extends ConsumerStatefulWidget {
  RoommateForm(
      {super.key,
      required this.capacity,
      required this.hostelName,
      required this.roomName,
      required this.numRoommates});
  String roomName;
  String hostelName;
  int capacity;
  int numRoommates;

  @override
  ConsumerState<RoommateForm> createState() => _RoommateFormState();
}

class _RoommateFormState extends ConsumerState<RoommateForm> {
  final List<GlobalKey<FormState>> _formKeyList = [];
  final storage = FirebaseFirestore.instance;

  int currentRoommateNumber = 0;
  String roommateEmail = "";
  bool isOverflow = false;
  var numOfRoommates = 0;
  bool isRunning = false;
  void addRoommate(int index) async {
    if (_formKeyList[index].currentState!.validate()) {
      _formKeyList[index].currentState!.save();
      try {
        final userCheck =
            await storage.collection('users').doc(roommateEmail).get();
        if (!userCheck.exists) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'No user exists with this email. Create an account to add here.')));
          setState(() {
            isRunning = false;
          });
          return;
        }
        final userLoc =
            await storage.collection('users').doc(roommateEmail).get();
        if (userLoc.data()!.containsKey('hostelName') &&
            userLoc.data()!['hostelName'] != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Hostel is already allocated to $roommateEmail. \n Hostel: ${userLoc['hostelName']} and Room: ${userLoc['roomName']}')));
          setState(() {
            isRunning = false;
          });
          return;
        }
        final loc = storage.collection('hostels').doc(widget.hostelName);

        await loc.collection('Roommates').doc(roommateEmail).set({
          'email': roommateEmail,
          'hostelName': widget.hostelName,
          'roomName': widget.roomName
        });
        await storage.collection('users').doc(roommateEmail).set(
            {'hostelName': widget.hostelName, 'roomName': widget.roomName},
            SetOptions(merge: true)).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error occured in updation')));
        });
        await loc.update({'numRoommates': FieldValue.increment(1)});
        if (currentRoommateNumber < numOfRoommates - 1) {
          setState(() {
            currentRoommateNumber += 1;
            roommateEmail = "";
            isRunning = false;
          });

          return;
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => RoomsScreen(hostelName: widget.hostelName),
        ));
      } catch (e) {}
    }
    setState(() {
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Add Roommate"),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              // Text("hi"),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Number of Roommates to be added"),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value == "") {
                    value = '0';
                  }
                  setState(() {
                    numOfRoommates = value == "" ? 0 : int.parse(value);

                    if (!(widget.capacity >=
                        int.parse(value) + widget.numRoommates)) {
                      numOfRoommates = widget.capacity - widget.numRoommates;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Capacity Overflow. Only ${widget.capacity - widget.numRoommates}  more roommates can be added.")));
                    }
                    for (int i = 0; i < numOfRoommates; i++) {
                      _formKeyList.add(GlobalKey<FormState>());
                    }
                  });
                },
              ),
              const Divider(),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                      child: Column(
                    children: [
                      Text(
                        "Roommate ${index + 1}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Form(
                        key: _formKeyList[index],
                        child: Column(children: [
                          TextFormField(
                            enabled: currentRoommateNumber == index,
                            decoration: const InputDecoration(
                              labelText: "Email ID",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name cannot be empty";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              roommateEmail = value.toLowerCase();
                            },
                          ),
                          if (currentRoommateNumber == index)
                            isRunning
                                ? const CircularProgressIndicator()
                                : TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isRunning = true;
                                      });
                                      addRoommate(index);
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text("Add Roommate"))
                        ]),
                      )
                    ],
                  ));
                },
                itemCount:
                    widget.capacity > numOfRoommates + widget.numRoommates
                        ? numOfRoommates
                        : widget.capacity - widget.numRoommates,
                shrinkWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
