import 'package:flutter/material.dart';
import 'package:hustle_stay/tools/tools.dart';
import 'package:transparent_image/transparent_image.dart';
import './attendance_screen.dart';
import './login_screen.dart';
import 'main_drawer.dart';

enum Names {
  bottomNavigationBarItem,
  screen,
}

class HomeScreen extends StatefulWidget {
  static const String routeName = "HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MainDrawer(),
      body: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  static String routeName = "HomeScreen";
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            maxRadius: 100,
            backgroundColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image:
                    'https://upload.wikimedia.org/wikipedia/en/thumb/d/d8/Indian_Institute_of_Information_Technology%2C_Raichur_Logo.svg/1200px-Indian_Institute_of_Information_Technology%2C_Raichur_Logo.svg.png',
              ),
            ),
          ),
          Text(
            'Hustle Stay',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('Hostel Life, Hustle Life, HustleStay Life')
        ],
      ),
    );
  }
}
