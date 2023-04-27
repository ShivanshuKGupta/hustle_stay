import 'package:flutter/material.dart';
import 'package:hustle_stay/providers/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/tools.dart';

import 'home_screen.dart';

class LoginScreen extends ConsumerWidget {
  static String routeName = "/";
  User user = User(type: UserType.student);

  final _formKey = GlobalKey<FormState>();

  _save(BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      await ref.read(userProvider.notifier).getDetails(user);
    } catch (e) {
      showMsg(context, e.toString());
      return;
    }
    if (!context.mounted) return;
    showMsg(context, "Logged In");
    Navigator.of(context).pushReplacementNamed(HomePage.routeName);
  }

  _reset() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                  if (value.length < 9) return "Length cannot be less than 9";
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
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _save(context, ref),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Login'),
                  ),
                  TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.delete),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
