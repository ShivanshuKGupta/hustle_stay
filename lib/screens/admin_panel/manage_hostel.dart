import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/hostels.dart';
import 'package:hustle_stay/screens/admin_panel/stats_hostel.dart';
import 'package:hustle_stay/screens/hostel/rooms/add_rooms.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';

import '../../models/common/operation.dart';

class ManageHostel extends StatefulWidget {
  const ManageHostel({super.key, required this.hostel});
  final Hostels hostel;
  @override
  State<ManageHostel> createState() => _ManageHostelState();
}

class _ManageHostelState extends State<ManageHostel> {
  List<Operations> catList = [
    Operations(
        cardColor: const Color.fromARGB(255, 98, 0, 238),
        operationName: 'Add Rooms',
        icon: const Icon(Icons.person_add_outlined)),
    Operations(
        cardColor: const Color.fromARGB(255, 239, 108, 0),
        operationName: 'Manage Rooms',
        icon: const Icon(Icons.room_preferences_sharp)),
    Operations(
        cardColor: const Color.fromARGB(255, 238, 0, 0),
        operationName: 'View Statistics and Analytics',
        icon: const Icon(Icons.bar_chart_rounded)),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 69),
        operationName: 'Delete Hostel',
        icon: const Icon(Icons.delete_forever)),
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = (screenWidth) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users & Permissions'),
      ),
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final Color cardColor = catList[index].cardColor!;

            final LinearGradient gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: brightness == Brightness.light
                  ? [
                      cardColor.withOpacity(0.2),
                      Colors.white,
                    ]
                  : [
                      cardColor.withOpacity(0.7),
                      Colors.black,
                    ],
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 8, 8),
              child: GestureDetector(
                  onTap: () {
                    switch (catList[index].operationName) {
                      case 'Add Rooms':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                AddRoom(hostelName: widget.hostel.hostelName)));
                        break;
                      case 'Manage Rooms':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RoomsScreen(
                                hostelName: widget.hostel.hostelName)));
                        break;
                      case 'View Statistics and Analytics':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => StatsPage(
                                hostelName: widget.hostel.hostelName)));
                        break;
                      default:
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RoomsScreen(
                                hostelName: widget.hostel.hostelName)));
                        break;
                    }
                  },
                  child: Container(
                    width: gridWidth,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient:
                          brightness == Brightness.light ? null : gradient,
                      color: brightness == Brightness.light
                          ? cardColor.withOpacity(0.2)
                          : null,
                      boxShadow: brightness == Brightness.light
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
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
                            catList[index].icon!.icon,
                            size: screenWidth * 0.3,
                          ),
                        ),
                        Divider(
                          color: brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          catList[index].operationName,
                          overflow: TextOverflow.clip,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: brightness == Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                        ),
                        Divider(
                          color: brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ],
                    ),
                  )),
            );
          },
          itemCount: catList.length,
        ),
      ),
    );
  }
}
