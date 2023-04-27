import 'package:flutter/material.dart';

import '../providers/user.dart';
import '../tools.dart';

class AddUserScreen extends StatelessWidget {
  static String routeName = "AddUserScreen";
  AddUserScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  User user = User(type: UserType.student);

  void _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    print("Adding user...");
    await addUser(user);
    showMsg(context, "User Added");
    print("Added user...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add user'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 9,
                    decoration: const InputDecoration(
                      label: Text("Roll number"),
                    ),
                    validator: (value) {
                      if (value == null) return "Roll number cannot be empty";
                      if (value.length < 9)
                        return "Length cannot be less than 9";
                      return null;
                    },
                    onSaved: (value) {
                      user.rollNo = value;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text("Password"),
                    ),
                    onSaved: (value) {
                      user.password = value;
                    },
                  ),
                  TextFormField(
                    maxLength: 50,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                    ),
                    validator: (value) {
                      if (value == null) return "Name is required";
                    },
                    onSaved: (value) {
                      user.name = value;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      label: Text("Email"),
                    ),
                    onSaved: (value) {
                      user.email = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Hostel"),
                    ),
                    onSaved: (value) {
                      user.hostel = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Room Number"),
                    ),
                    onSaved: (value) {
                      user.room = value;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      label: Text("Phone Number"),
                    ),
                    onSaved: (value) {
                      user.phone = value;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _save(context),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save'),
                      ),
                      TextButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.delete),
                        label: const Text('Reset'),
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
