import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hustle_stay/screens/add_hostel_screen.dart';
import 'package:hustle_stay/screens/add_user_screen.dart';
import 'package:hustle_stay/screens/login_screen.dart';
import 'package:hustle_stay/screens/profile_screen.dart';
import './screens/attendance_screen.dart';
import './screens/home_screen.dart';

void main(List<String> args) {
  runApp(
    const ProviderScope(child: MyApp()),
  );
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
        HomePage.routeName: (_) => const HomeScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        AttendanceScreen.routeName: (_) => const AttendanceScreen(),
        AddUserScreen.routeName: (_) => AddUserScreen(),
        ProfileScreen.routeName: (_) => ProfileScreen(),
        // '/': (_) => AddHostel(),
      },
    );
  }
}
