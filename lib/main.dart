import 'package:flutter/material.dart';
import './screens/attendance_screen.dart';
import './screens/home_screen.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => HomeScreen(),
        AttendanceScreen.routeName: (_) => AttendanceScreen()
      },
    );
  }
}
