import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/complaints_screen.dart';
import 'package:hustle_stay/screens/settings_screen.dart';

import 'package:hustle_stay/tools.dart';

import 'main_drawer.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        icon: Icon(Icons.home_rounded),
        label: 'Home',
        tooltip: "Hustle Stay",
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
    switch (_currentIndex) {
      case 0:
        body = Container();
        break;
      case 1:
        body = const ComplaintsScreen();
        break;
      case 2:
        body = Container();
        break;
      case 3:
        body = Container();
        break;
      case 4:
        body = const SettingsScreen();
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title:
              bottomNavigationBarItems[_currentIndex].tooltip ?? "Hustle Stay",
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: body,
    );
  }
}
