import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: linkText(
          context,
          title: 'View Readme.md',
          url:
              'https://github.com/ShivanshuKGupta/hustle_stay/blob/master/README.md',
        ),
      ),
    );
  }
}
