import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/widgets/settings/current_user_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    const duration = Duration(milliseconds: 300);
    int i = 1;
    final widgetList = [
      if (currentUser.email != null) const CurrentUserTile(),
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
            duration: duration * 2, curve: Curves.decelerate, begin: 0, end: 1),
        itemBuilder: (ctx, index) => widgetList[index],
      ),
    );
  }
}
