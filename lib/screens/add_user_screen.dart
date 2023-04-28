import 'package:flutter/material.dart';

import '../models/hostel.dart';
import '../models/user.dart';
import '../tools/tools.dart';
import '../tools/user_tools.dart';

class AddUserScreen extends StatefulWidget {
  static String routeName = "AddUserScreen";
  AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  User user = User(type: UserType.student);

  bool _isLoading = false;

  String? dropdownValue;
  @override
  void initState() {
    super.initState();
    fetchAllHostels().then((value) {
      setState(() {
        dropdownValue = allHostels.first.name;
      });
    });
  }

  void _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      user.hostel = dropdownValue;
      await uploadUser(user);
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
    if (context.mounted) {
      showMsg(context, "User Added");
    }
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
                      if (value.length < 9) {
                        return "Length cannot be less than 9";
                      }
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
                  DropdownButtonFormField(
                    value: dropdownValue,
                    items: [
                      for (int i = 0; i < allHostels.length; ++i)
                        DropdownMenuItem(
                          value: allHostels[i].name,
                          child: Text(allHostels[i].name),
                        ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Hostel is required";
                    },
                    onChanged: (str) {
                      setState(() {
                        dropdownValue = str!;
                      });
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
                        onPressed: _isLoading ? null : () => _save(context),
                        icon: const Icon(Icons.save_rounded),
                        label: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Save'),
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
