import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/profile_image.dart';

class EditProfile extends StatefulWidget {
  EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  UserData user = currentUser;

  Future<void> save(context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      updateUserData(user);
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ProfileImage(onChanged: (img) {}),
                Text(
                  currentUser.email!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Divider(),
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text("Name"),
                  ),
                  initialValue: currentUser.name,
                  validator: (name) {
                    return Validate.name(name);
                  },
                  onSaved: (value) {
                    user.name = value!.trim();
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    label: Text("Phone Number"),
                  ),
                  initialValue: currentUser.phoneNumber,
                  validator: (name) {
                    return Validate.phone(name, required: false);
                  },
                  onSaved: (value) {
                    user.phoneNumber = value!.trim();
                  },
                ),
                TextFormField(
                  maxLength: 200,
                  keyboardType: TextInputType.streetAddress,
                  decoration: const InputDecoration(
                    label: Text("Address"),
                  ),
                  initialValue: currentUser.address,
                  validator: (name) {
                    return Validate.text(name, required: false);
                  },
                  onSaved: (value) {
                    user.address = value!.trim();
                  },
                ),
                // TODO: add more fields about the person here
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () {
                              save(context);
                            },
                      icon: _loading
                          ? circularProgressIndicator()
                          : const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
