import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/home_screen.dart';

SharedPreferences? prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // for loading settings
  prefs = await SharedPreferences.getInstance();
  // for fetching user info
  final auth = FirebaseAuth.instance;
  if (auth.currentUser != null) {
    currentUser = await fetchUserData(auth.currentUser!.email!);
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hustle Stay',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            seedColor: Colors.blue,
          ),
          textTheme: GoogleFonts.quicksandTextTheme().apply(
            bodyColor: settings.darkMode ? Colors.white : Colors.black,
            displayColor: settings.darkMode ? Colors.white : Colors.black,
          )),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, user) {
            if (user.hasData) return HomeScreen();
            return AuthScreen();
          }),
    );
  }
}
