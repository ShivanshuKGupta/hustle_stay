import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/attendance_screen.dart';
import 'package:hustle_stay/screens/complaints/complaints_screen.dart';
import 'package:hustle_stay/screens/hostel/hostel_screen.dart';
import 'package:hustle_stay/screens/requests/requests_screen.dart';
import 'package:hustle_stay/screens/settings/settings_screen.dart';
import 'package:hustle_stay/screens/vehicle/vehicle_screen.dart';
import 'package:hustle_stay/tools.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: ref.read(settingsProvider).currentPage);
    initializeEverything().onError((error, stackTrace) {
      everythingInitialized.value = null;
      showMsg(context, error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    bool canExit = false;
    int i = 0;
    List<Widget> bodyList = [
      currentUser.type == 'student'
          ? const AttendanceScreen()
          : const HostelScreen(),
      const ComplaintsScreen(),
      VehicleScreen(),
      const RequestsScreen(),
      const SettingsScreen(),
    ];
    return WillPopScope(
      onWillPop: () async {
        if (canExit) return true;
        showMsg(context, 'Press back once again to exit.');
        canExit = true;
        await Future.delayed(const Duration(seconds: 3)).then((value) => null);
        canExit = false;
        return false;
      },
      child: Scaffold(
          extendBody: true,
          bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 2),
            child: GlassWidget(
              radius: 50,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  // color: colorScheme.onBackground.withOpacity(0.8),
                ),
                child: GNav(
                  selectedIndex: settings.currentPage,
                  onTabChange: (value) {
                    if ((settings.currentPage - value).abs() > 1) {
                      _pageController.jumpToPage(value);
                    } else {
                      _switchPage(value);
                    }
                  },
                  gap: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  tabBackgroundColor: colorScheme.onBackground.withOpacity(0.8),
                  activeColor: colorScheme.inversePrimary,
                  color: colorScheme.onBackground,
                  tabs: [
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.calendar_month_rounded
                          : Icons.calendar_month_outlined,
                      text: 'Attendance',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.info_rounded
                          : Icons.info_outline_rounded,
                      text: 'Complaints',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.airport_shuttle_rounded
                          : Icons.airport_shuttle_outlined,
                      text: 'Vehicle',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.assignment_turned_in_rounded
                          : Icons.assignment_turned_in_outlined,
                      text: 'Requests',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.settings_rounded
                          : Icons.settings_outlined,
                      text: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: PageView(
            pageSnapping: true,
            controller: _pageController,
            onPageChanged: (value) {
              setState(() => settings.currentPage = value);
              settingsClass.saveSettings();
            },
            children: bodyList,
          )
          // bodyList[settings.currentPage],
          ),
    );
  }

  void _switchPage(int value) {
    _pageController.animateToPage(
      value,
      curve: Curves.decelerate,
      duration: const Duration(milliseconds: 500),
    );
  }
}
