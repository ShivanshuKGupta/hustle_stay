import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/complaints/complaints_screen.dart';
import 'package:hustle_stay/screens/hostel/hostel_screen.dart';
import 'package:hustle_stay/screens/hostel/rooms/complete_details_screen.dart';
import 'package:hustle_stay/screens/requests/requests_screen.dart';
import 'package:hustle_stay/screens/settings/settings_screen.dart';
import 'package:hustle_stay/tools.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: ref.read(settingsProvider).currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    int i = 0;
    List<Widget> bodyList = [
      currentUser.readonly.type == 'student'
          ? CompleteDetails(
              hostelName: currentUser.readonly.hostelName ?? '',
              roomName: currentUser.readonly.roomName ?? '',
              user: UserData(
                  email: currentUser.email,
                  address: currentUser.address,
                  imgUrl: currentUser.imgUrl,
                  name: currentUser.name,
                  phoneNumber: currentUser.phoneNumber),
              roommateData: RoommateData(email: currentUser.email!))
          : const HostelScreen(),
      const ComplaintsScreen(),
      const Center(
        child: Text('Home Screen'),
      ),
      const RequestsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 2),
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
                    _pageController.animateToPage(
                      value,
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 500),
                    );
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
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    text: 'Home',
                  ),
                  GButton(
                    icon: settings.currentPage == i++
                        ? Icons.airport_shuttle_rounded
                        : Icons.airport_shuttle_outlined,
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
        );
  }
}
