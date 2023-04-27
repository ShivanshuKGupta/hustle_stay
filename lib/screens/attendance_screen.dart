import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/add_hostel_screen.dart';
import 'package:hustle_stay/tools/tools.dart';

import 'attendance_sheet_screen.dart';
import 'main_drawer.dart';

class AttendanceScreen extends StatelessWidget {
  static const String routeName = "AttendanceScreen";
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('Choose a hostel'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AddHostel(),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
          )
        ],
      ),
      body: GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400, childAspectRatio: 3 / 2),
        children: [
          gridTile(
            context,
            'Krishna Hostel',
            'Boys Hostel',
            Image.network(
                'https://iiitr.ac.in/assets/images/campus/hostel/2.jpeg'),
          ),
          gridTile(
            context,
            'Tungabhadra Hostel',
            'Girls Hostel',
            Image.network(
                'https://iiitr.ac.in/assets/images/campus/hostel/1.jpeg'),
          ),
          gridTile(
            context,
            'Federal Hostel',
            'Trash Hostel',
            Image.network(
                'https://content.jdmagicbox.com/comp/raichur/a4/9999p8532.8532.190924162150.l8a4/catalogue/federal-public-school-english-medium-and-federal-pu-college-and-degree-and-ded-college-raichur-luneimezla.jpg'),
          ),
        ],
      ),
    );
  }
}

Widget gridTile(
    BuildContext context, String title, String subtitle, Image img) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => AttendanceSheetScreen(hostelName: title),
        ),
      );
    },
    child: Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          subtitle: Text(subtitle),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        child: img,
      ),
    ),
  );
}
