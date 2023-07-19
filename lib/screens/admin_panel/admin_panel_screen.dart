import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/admin_panel/manage_categories.dart';
import 'package:hustle_stay/screens/admin_panel/manage_hostel_attendance.dart';
import 'package:hustle_stay/screens/admin_panel/manage_requests.dart';
import 'package:hustle_stay/screens/admin_panel/manage_user_permission.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class Operations {
  final String operationName;
  final Icon icon;
  final Color cardColor;
  Operations(
      {required this.cardColor,
      required this.operationName,
      required this.icon});
}

class _AdminPanelState extends State<AdminPanel> {
  List<Operations> catList = [
    Operations(
        cardColor: const Color.fromARGB(255, 98, 0, 238),
        operationName: 'Manage Users & Permissions',
        icon: const Icon(Icons.person_rounded)),
    Operations(
        cardColor: const Color.fromARGB(255, 239, 108, 0),
        operationName: 'Manage Categories',
        icon: const Icon(Icons.category)),
    Operations(
        cardColor: const Color.fromARGB(255, 238, 0, 0),
        operationName: 'Manage Requests',
        icon: const Icon(Icons.request_quote)),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 69),
        operationName: 'Manage Hostels & Attendance',
        icon: const Icon(Icons.calendar_month))
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = (screenWidth) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final Color cardColor = catList[index].cardColor;

            final LinearGradient gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                brightness == Brightness.light
                    ? cardColor.withOpacity(0.4)
                    : cardColor.withOpacity(0.7),
                Colors.black,
              ],
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 8, 8),
              child: GestureDetector(
                onTap: () {
                  switch (catList[index].operationName) {
                    case 'Manage Users & Permissions':
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ManageUsers()));
                      break;
                    case 'Manage Categories':
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ManageCategories()));
                      break;
                    case 'Manage Requests':
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ManageRequest()));
                      break;
                    case 'Manage Hostels & Attendance':
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ManageHostel()));
                      break;
                    default:
                  }
                },
                child: Container(
                  width: gridWidth,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: brightness == Brightness.light
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Icon(
                          catList[index].icon.icon,
                          size: screenWidth * 0.3,
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      Text(
                        catList[index].operationName,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Divider(color: Colors.white),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: catList.length,
        ),
      ),
    );
  }
}
