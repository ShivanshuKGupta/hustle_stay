import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/auth/auth_form.dart';

/// The Authentication Screen which shows up when the user logs in
/// It is just a wrapper Scaffold around [AuthForm]
class AuthScreen extends ConsumerWidget {
  AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: const Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
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
