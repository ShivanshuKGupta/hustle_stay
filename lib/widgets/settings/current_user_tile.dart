import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      title: Text(currentUser.name ?? "Error"),
      subtitle: Text(
        currentUser.email!,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: IconButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
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
          icon: const Icon(Icons.edit_rounded)),
    ).animate().fade().slideX(begin: 1, end: 0, curve: Curves.decelerate);
  }
}
