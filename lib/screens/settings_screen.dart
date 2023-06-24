import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/edit_profile_screen.dart';

import '../models/user.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    final widgetList = [
      if (currentUser.email != null)
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: currentUser.imgUrl == null
                    ? null
                    : CachedNetworkImageProvider(currentUser.imgUrl!),
                radius: 50,
                child: currentUser.imgUrl != null
                    ? null
                    : const Icon(
                        Icons.person_rounded,
                        size: 50,
                      ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: fetchUserData(currentUser.email!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return FutureBuilder(
                          future: fetchUserData(currentUser.email!,
                              src: Source.cache),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              currentUser = snapshot.data!;
                            }
                            return userTile(
                                context, currentUser, settingsClass);
                          });
                    }
                    currentUser = snapshot.data!;
                    return userTile(context, currentUser, settingsClass);
                  },
                ),
              ),
            ],
          ),
        ),
      // TODO: add the profile avatar here and a pencil icon on top of it when clicked should move the user to view/edit profile page
      Column(
        children: [
          SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                'Turn ${settings.darkMode ? "off" : "on"} Dark Mode',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              value: settings.darkMode,
              onChanged: (value) {
                settings.darkMode = value;
                settingsClass.notifyListeners();
              }),
          SwitchListTile(
            value: false,
            title: const Text('Notifications[Not Available]'),
            subtitle: Text(
              'Receive notifications even when the app is closed',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            isThreeLine: true,
            onChanged: null,
          ),
          ListTile(
            title: Text(
              'Sign Out',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.red,
                  ),
            ),
            onTap: () {
              while (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              settingsClass.clearSettings();
              auth.signOut();
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      body: ListView.separated(
        itemCount: widgetList.length,
        separatorBuilder: (ctx, _) => const Divider(),
        itemBuilder: (ctx, index) => widgetList[index],
      ),
    );
  }

  Widget userTile(context, UserData currentUser, settingsClass) {
    return ListTile(
      title: Text(currentUser.name ??
          "Error"), // TODO: store other details about the user like name
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
    );
  }
}
