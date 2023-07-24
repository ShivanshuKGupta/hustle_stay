import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';

class _Settings {
  /// whether dark mode is on
  bool darkMode = false;

  /// the last visited page
  int currentPage = 2;

  /// Introduction screen visisted
  bool introductionScreenVisited = false;

  /// Complaints Screen Sorting Parameters
  /// used for showing complaints in groups and in a certain order
  String complaintsGrouping = "none";

  /// The groupBy in Stats of ComplaintsScreen
  String groupBy = 'Category';

  /// The groupBy in Stats of ComplaintsScreen
  String interval = 'Day';

  /// converts setting parameters into a string
  String encode() {
    return json.encode({
      "darkMode": darkMode,
      "currentPage": currentPage,
      "introductionScreenVisited": introductionScreenVisited,
      "complaintsGrouping": complaintsGrouping,
      "groupBy": groupBy,
      "interval": interval,
    });
  }

  /// converts string into setting parameters
  void load(String str) {
    final settings = json.decode(str);
    darkMode = settings["darkMode"] ?? false;
    introductionScreenVisited = settings["introductionScreenVisited"] ?? false;
    currentPage = settings["currentPage"] ?? 2;
    complaintsGrouping = (settings["complaintsGrouping"] ?? complaintsGrouping);
    groupBy = (settings["groupBy"] ?? 'Category');
    interval = (settings["interval"] ?? 'Day');
  }
}

class _SettingsProvider extends StateNotifier<_Settings> {
  /// loading settings on startup
  _SettingsProvider() : super(_Settings()) {
    loadSettings();
  }

  /// loads settings previously stored using shared preferences
  Future<bool> loadSettings() async {
    state.load(prefs!.getString('settings') ?? "{}");
    notifyListeners();
    return true;
  }

  /// saves settings onto the device using shared preferences
  Future<bool> saveSettings() async {
    prefs!.setString('settings', state.encode());
    return true;
  }

  /// deletes previously stored settings on the device
  /// and also reloads the setting parameters
  Future<void> clearSettings() async {
    await prefs!.clear();
    loadSettings();
  }

  /// If watch listeners do not react to changes automatically,
  /// then use this function to notify all watch listeners
  void notifyListeners() {
    saveSettings();
    final _Settings savedSettings = state;
    state = _Settings();
    state = savedSettings;
  }
}

/// use notifier on this object to access the settings class
final settingsProvider = StateNotifierProvider<_SettingsProvider, _Settings>(
    (ref) => _SettingsProvider());
