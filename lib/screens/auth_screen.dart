import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hustle_stay/widgets/auth_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<void> onSubmit(
    String email,
    String password,
  ) async {
    final auth = FirebaseAuth.instance;
    UserCredential userCredential;
    userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    // TODO: use this userCredential to update the local database about the user
    debugPrint("userCredential = $userCredential");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AuthForm(onSubmit: onSubmit),
            ),
          ),
        ),
      ),
    );
  }
}
