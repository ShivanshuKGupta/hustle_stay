import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/auth/edit_profile_screen.dart';

class CurrentUserTile extends ConsumerWidget {
  const CurrentUserTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsClass = ref.read(settingsProvider.notifier);
    return ListTile(
      title: Text(currentUser.name ?? currentUser.email!),
      subtitle: Text(
        currentUser.email!,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: () async {
        // ignore: use_build_context_synchronously
        if (await Navigator.of(context).push<bool?>(
              MaterialPageRoute(
                builder: (ctx) => EditProfile(
                  user: currentUser,
                ),
              ),
            ) ==
            true) {
          settingsClass.notifyListeners();
        }
      },
    );
  }
}
