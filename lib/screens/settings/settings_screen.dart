import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/auth/edit_profile_screen.dart';
import 'package:hustle_stay/screens/chat/image_preview.dart';
import 'package:hustle_stay/tools.dart';

import '../../models/user.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    const duration = Duration(milliseconds: 500);
    int i = 1;
    final widgetList = [
      if (currentUser.email != null)
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: currentUser.imgUrl == null
                    ? null
                    : () {
                        navigatorPush(
                          context,
                          ImagePreview(
                            image: CachedNetworkImage(
                              imageUrl: currentUser.imgUrl!,
                            ),
                          ),
                        );
                      },
                icon: CircleAvatar(
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
                )
                    .animate()
                    .fade()
                    .slideX(begin: -1, end: 0, curve: Curves.decelerate),
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
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  value: settings.darkMode,
                  onChanged: (value) {
                    settings.darkMode = value;
                    settingsClass.notifyListeners();
                  })
              .animate()
              .then(
                  delay: Duration(milliseconds: duration.inMilliseconds * i++))
              .fade(duration: duration)
              .slideX(
                  curve: Curves.decelerate,
                  begin: 1,
                  end: 0,
                  duration: duration),
          SwitchListTile(
            value: false,
            title: const Text('Notifications[Not Available]'),
            subtitle: Text(
              'Receive notifications even when the app is closed',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            isThreeLine: true,
            onChanged: null,
          )
              .animate()
              .then(
                  delay: Duration(milliseconds: duration.inMilliseconds * i++))
              .fade(duration: duration)
              .slideX(
                  curve: Curves.decelerate,
                  begin: 1,
                  end: 0,
                  duration: duration),
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
          )
              .animate()
              .then(
                  delay: Duration(milliseconds: duration.inMilliseconds * i++))
              .fade(duration: duration)
              .slideX(
                  curve: Curves.decelerate,
                  begin: 1,
                  end: 0,
                  duration: duration),
        ],
      ),
    ];

    return Scaffold(
      body: ListView.separated(
        itemCount: widgetList.length,
        separatorBuilder: (ctx, _) => const Divider().animate().scaleX(
            duration: duration, curve: Curves.decelerate, begin: 0, end: 1),
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
    ).animate().fade().slideX(begin: 1, end: 0, curve: Curves.decelerate);
  }
}
