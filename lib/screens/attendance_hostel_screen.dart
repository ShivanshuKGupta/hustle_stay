import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

import 'main_drawer.dart';

class HostelScreen extends StatelessWidget {
  const HostelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('Choose a hostel'),
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
                'https://iiitr.ac.in/assets/images/campus/hostel/1.jpeg'),
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
      showMsg(context, '$title selected');
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
