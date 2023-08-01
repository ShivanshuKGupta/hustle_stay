import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/providers/settings.dart';

class DarkLightModeIconButton extends ConsumerWidget {
  const DarkLightModeIconButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final settings = ref.watch(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    return IconButton(
      onPressed: () {
        if (settings.autoDarkMode) {
          settings.autoDarkMode = false;
          settings.darkMode =
              !(MediaQuery.of(context).platformBrightness == Brightness.dark);
        } else {
          if (MediaQuery.of(context).platformBrightness ==
              (settings.darkMode ? Brightness.dark : Brightness.light)) {
            settings.autoDarkMode = true;
          }
          settings.darkMode = !settings.darkMode;
        }
        settingsClass.notifyListeners();
      },
      icon: Icon(
        settings.autoDarkMode
            ? Icons.brightness_auto_rounded
            : !settings.darkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
      ),
    );
  }
}
