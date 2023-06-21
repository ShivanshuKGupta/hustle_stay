import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/home_screen.dart';
// import 'package:hustle_stay/models/hostels.dart';
import '../tools.dart';
import '../widgets/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddHostelForm extends StatefulWidget {
  AddHostelForm();

  @override
  _AddHostelFormState createState() => _AddHostelFormState();
}

class _AddHostelFormState extends State<AddHostelForm> {
  final _formKey = GlobalKey<FormState>();
  Future<void> uploadHostel(String hostelName, String hostelType, int capacity,
      int numberOfRooms, int numberOfFloorsorBlocks) async {
    final store = FirebaseFirestore.instance;
    // print(store);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('hostel_images')
        .child('${hostelName}.jpg');

    await storageRef.putFile(_selectedImage!);
    final imageUrl = await storageRef.getDownloadURL();
    await store.collection('hostels').doc('$hostelName').set({
      "hostelName": hostelName,
      "hostelType": hostelType,
      "numberOfRooms": numberOfRooms,
      "numberOfFloorsorBlocks": numberOfFloorsorBlocks,
      "capacity": capacity,
      "imageUrl": imageUrl
    });

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  File? _selectedImage;
  String hostelName = '';
  String hostelType = 'Boys';
  int capacity = 0;
  int numberOfRooms = 0;
  int numberOfFloorsorBlocks = 0;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // print(hostelName);
      // print(hostelType);
      // print(capacity);
      // print(numberOfRooms);
      // print(numberOfFloorsorBlocks);
      await uploadHostel(hostelName, hostelType, capacity, numberOfRooms,
          numberOfFloorsorBlocks);

      Navigator.pop(context);
    }
  }

  List<DropdownMenuItem<String>> dropdownItems = [
    DropdownMenuItem(
      value: 'Boys',
      child: Text('Boys'),
    ),
    DropdownMenuItem(
      value: 'Girls',
      child: Text('Girls'),
    ),
    DropdownMenuItem(
      value: 'Co-Ed',
      child: Text('Co-Ed'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: 'Add Hostel',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              child: Icon(Icons.person_rounded),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImagePickerWidget(
                    onpickImage: (pickedImage) {
                      _selectedImage = pickedImage;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(label: Text('Hostel Name')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the hostel name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      hostelName = value!;
                    },
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField(
                    decoration:
                        InputDecoration(label: const Text('Hostel Type')),
                    items: dropdownItems,
                    value: 'Boys',
                    onChanged: (value) {
                      setState(() {
                        hostelType = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a hostel type.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the capacity.';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      capacity = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Number of Rooms'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of rooms.';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      numberOfRooms = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Number of Floors/Blocks'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of floors or blocks.';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      numberOfFloorsorBlocks = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Add Hostel',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
