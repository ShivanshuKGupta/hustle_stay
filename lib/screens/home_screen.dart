import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/complaints/complaints_screen.dart';
import 'package:hustle_stay/screens/drawers/main_drawer.dart';
import 'package:hustle_stay/screens/hostel/hostel_screen.dart';
import 'package:hustle_stay/screens/settings/settings_screen.dart';
import 'package:hustle_stay/tools.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    const duration = Duration(milliseconds: 1000);
    List<BottomNavigationBarItem> bottomNavigationBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.co_present_rounded),
        label: 'Attendance',
        tooltip: "Attendance",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.report_rounded),
        label: 'Complaints',
        tooltip: "Complaints",
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.airport_shuttle_rounded)
            .animate(target: settings.currentPage == 2 ? 1 : 0)
            .shake(),
        label: 'Vehicle',
        tooltip: "Vehicle Request",
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_rounded)
            .animate(target: settings.currentPage == 3 ? 1 : 0)
            .rotate(
              duration: duration,
              curve: Curves.decelerate,
              begin: 1,
              end: 0,
            ),
        label: 'Settings',
        tooltip: "Settings",
      ),
    ];
    List<Widget> actions = [
      IconButton(
        onPressed: () {
          showMsg(context, 'TODO: show profile page');
        },
        icon: CircleAvatar(
          backgroundImage: currentUser.imgUrl == null
              ? null
              : CachedNetworkImageProvider(currentUser.imgUrl!),
          child: currentUser.imgUrl != null
              ? null
              : const Icon(
                  Icons.person_rounded,
                ),
        ),
      )
    ];
    Widget body = Container();
    switch (settings.currentPage) {
      case 0:
        body = const HostelScreen();
        break;
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
        actions: actions,
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
