import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';

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
        operationName: 'Manage Hostels and Attendance',
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
      body: Center(
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
                    ? cardColor.withOpacity(0.9)
                    : cardColor.withOpacity(0.7),
                cardColor,
              ],
            );

            return Padding(
              padding: EdgeInsets.fromLTRB(2, 2, 8, 8),
              child: Container(
                width: gridWidth,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      catList[index].icon.icon,
                      size: screenWidth * 0.3,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Text(
                      catList[index].operationName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Divider(color: Colors.white),
                  ],
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
