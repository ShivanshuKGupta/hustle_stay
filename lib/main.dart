import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './screens/attendance_screen.dart';
import './screens/home_screen.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 0, 9, 131),
        ),
        textTheme:
            GoogleFonts.quicksandTextTheme().apply(bodyColor: Colors.white));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      routes: {
        '/': (_) => const HomeScreen(),
        AttendanceScreen.routeName: (_) => const AttendanceScreen()
      },
    );
  }
}
