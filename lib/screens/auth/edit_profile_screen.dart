import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/widgets/edit_profile.dart';

class EditProfile extends ConsumerWidget {
  late final UserData user;

  EditProfile({super.key, UserData? user}) {
    this.user = user ?? UserData();
  }

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (user.email == currentUser.email)
            ElevatedButton.icon(
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                currentUser = UserData();
                ref.read(settingsProvider.notifier).clearSettings();
                auth.signOut();
              },
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: EditProfileWidget(
        user: user,
      ),
    );
  }
}
