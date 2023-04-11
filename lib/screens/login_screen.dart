import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(50),
      child: Card(
        child: TextButton.icon(
          label: const Text('Login'),
          icon: const Icon(Icons.login_rounded),
          onPressed: () {},
        ),
      ),
    );
  }
}
