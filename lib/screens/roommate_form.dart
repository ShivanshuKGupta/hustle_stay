import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../tools.dart';

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
  final storage = FirebaseFirestore.instance;
  // final _formKey = GlobalKey<FormState>();
  int currentRoommateNumber = 0;
  String roommateName = "";
  String roommateEmail = "";
  String roommateRollNum = "";
  var numOfRoommates = 0;
  bool isRunning = false;
  void addRoommate(GlobalKey<FormState> formkey) async {
    if (!formkey.currentState!.validate()) {
      return;
    }
    formkey.currentState!.save();
    try {
      final loc = storage
          .collection('hostels')
          .doc(widget.hostelName)
          .collection('Rooms')
          .doc(widget.roomName);

      await loc.collection('Roommates').doc(roommateEmail).set({
        'name': roommateName,
        'email': roommateEmail,
        "rollNumber": roommateRollNum,
      });
      await loc.update({'numRoommates': FieldValue.increment(1)});
      setState(() {
        if (currentRoommateNumber < numOfRoommates - 1) {
          currentRoommateNumber += 1;
          roommateName = "";
          roommateEmail = "";
          roommateRollNum = "";
          isRunning = false;
        }
        Navigator.of(context).pop();
      });
    } catch (e) {
      print(e);
    }
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
                decoration: InputDecoration(
                  label: Text("Number of Roommates to be added"),
                ),
                onChanged: (value) {
                  setState(() {
                    numOfRoommates = int.parse(value);
                  });
                },
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final _formKey = GlobalKey<FormState>();

                  return widget.capacity >
                          widget.numRoommates + currentRoommateNumber
                      ? Card(
                          child: Column(
                          children: [
                            Text(
                              "Roommate ${index + 1}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(children: [
                                TextFormField(
                                  enabled: index == currentRoommateNumber,
                                  decoration: InputDecoration(
                                    labelText: "Enter Roommate name",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Name cannot be empty";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    roommateName = value.toLowerCase();
                                  },
                                ),
                                TextFormField(
                                  enabled: currentRoommateNumber == index,
                                  decoration: InputDecoration(
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
                                    roommateEmail = value;
                                  },
                                ),
                                TextFormField(
                                  enabled: currentRoommateNumber == index,
                                  decoration: InputDecoration(
                                    labelText: "Roll No.",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Roll Number cannot be empty";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    roommateRollNum = value.toUpperCase();
                                  },
                                ),
                                if (currentRoommateNumber == index)
                                  isRunning
                                      ? CircularProgressIndicator()
                                      : TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              isRunning = true;
                                            });
                                            addRoommate(_formKey);
                                          },
                                          icon: Icon(Icons.add_circle_outline),
                                          label: Text("Add Roommate"))
                              ]),
                            )
                          ],
                        ))
                      : Text(
                          "Full Capacity reached. No more Rooms can be added.",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.red),
                        );
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
