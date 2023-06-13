import 'package:flutter/material.dart';

import 'package:hustle_stay/tools.dart';

import 'main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: 'Hustle Stay'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          )
        ],
      ),
      drawer: const Drawer(elevation: 5, child: MainDrawer()),
      body: Container(),
    );
  }
}
