import 'package:flutter/material.dart';
import './screens/attendance_screen.dart';
import './screens/home_screen.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const HomeScreen(),
        AttendanceScreen.routeName: (_) => const AttendanceScreen()
      },
    );
  }
}
