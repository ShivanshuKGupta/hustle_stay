import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/user.dart';

import 'package:hustle_stay/widgets/auth_form.dart';

class AuthScreen extends ConsumerWidget {
  AuthScreen({super.key});

  Future<void> login(
    String email,
    String password,
  ) async {
    final auth = FirebaseAuth.instance;
    UserCredential userCredential;
    userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    currentUser = await fetchUserData(userCredential.user!.email!);
  }

  Widget? ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AuthForm(
                onSubmit: login,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
