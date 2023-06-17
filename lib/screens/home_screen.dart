import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/complaints_screen.dart';
import 'package:hustle_stay/screens/settings_screen.dart';

import 'package:hustle_stay/tools.dart';

import 'main_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    var bottomNavigationBarItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.co_present_rounded),
        label: 'Attendance',
        tooltip: "Attendance",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.report_rounded),
        label: 'Complaints',
        tooltip: "Complaints",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.airport_shuttle_rounded),
        label: 'Vehicle',
        tooltip: "Vehicle Request",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_rounded),
        label: 'Settings',
        tooltip: "Settings",
      ),
    ];
    Widget body = Container();
    switch (settings.currentPage) {
      case 1:
        body = const ComplaintsScreen();
        break;
      case 3:
        body = const SettingsScreen();
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: bottomNavigationBarItems[settings.currentPage].tooltip ??
              "Hustle Stay",
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              child: Icon(Icons.person_rounded),
            ),
          )
        ],
      ),
      drawer: const Drawer(elevation: 5, child: MainDrawer()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationBarItems,
        currentIndex: settings.currentPage,
        onTap: (index) {
          setState(() {
            settings.currentPage = index;
          });
          ref.read(settingsProvider.notifier).saveSettings();
        },
      ),
      body: body,
    );
  }
}
