import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../tools/tools.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = "ProfileScreen";
  ProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.clear();
              });
              while (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => LoginScreen()));
            },
            icon: Icon(Icons.logout_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 80,
                    child: currentUser.img == null
                        ? const Icon(
                            Icons.person,
                            size: 80,
                          )
                        : Image.network(currentUser.img!),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLength: 9,
                    readOnly: true,
                    decoration: const InputDecoration(
                      label: Text("Roll number"),
                    ),
                    initialValue: currentUser.rollNo,
                    validator: (value) {
                      if (value == null) return "Roll number cannot be empty";
                      if (value.length < 9)
                        return "Length cannot be less than 9";
                      return null;
                    },
                    onSaved: (value) {
                      // currentUser.rollNo = value;
                    },
                  ),
                  TextFormField(
                    maxLength: 50,
                    readOnly: true,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                    ),
                    initialValue: currentUser.name,
                    validator: (value) {
                      if (value == null) return "Name is required";
                    },
                    onSaved: (value) {
                      currentUser.name = value;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                    initialValue: currentUser.email,
                    decoration: const InputDecoration(
                      label: Text("Email"),
                    ),
                    onSaved: (value) {
                      currentUser.email = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Hostel"),
                    ),
                    onSaved: (value) {
                      currentUser.hostel = value;
                    },
                    initialValue: currentUser.hostel,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Room Number"),
                    ),
                    readOnly: true,
                    initialValue: currentUser.room,
                    onSaved: (value) {
                      currentUser.room = value;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      label: Text("Phone Number"),
                    ),
                    initialValue: currentUser.phone,
                    readOnly: true,
                    onSaved: (value) {
                      currentUser.phone = value;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  void _reset() {
    _formKey.currentState!.reset();
  }
}
