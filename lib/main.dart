import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/auth/auth_screen.dart';
import 'package:hustle_stay/screens/home_screen.dart';
import 'package:hustle_stay/screens/intro/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

/// Shared Preferences Object
/// Used for saving/loading settings
SharedPreferences? prefs;

/// Instead of creating multiple instances of the same object
/// I created then altogether here
final auth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;

/// Main function
void main() async {
  // Just to show errors not so rudely
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          ':-( Something went wrong!',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        Text(
          '\n${details.exception}',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const Text(
          'Contact shivanshukgupta or sanidhayasharma141 on linkedin for support\n',
          textAlign: TextAlign.center,
        ),
      ],
    ));
  };
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing Firebase SDK
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initializing prefs here in main to avoid any delay in activating settings
  prefs = await SharedPreferences.getInstance();
  // Fetching CurrentUser Info
  if (auth.currentUser != null) {
    currentUser = await fetchUserData(auth.currentUser!.email!);
  }
  runApp(const ProviderScope(child: HustleStayApp()));
}

/// The main app widget
class HustleStayApp extends ConsumerWidget {
  const HustleStayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // the settings object
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
        ),
      ),

      /// The app switches from Auth Screen to HomeScreen
      /// according to auth state
      home: settings.introductionScreenVisited
          ? StreamBuilder(
              stream: auth.authStateChanges(),
              builder: (ctx, user) {
                return user.hasData ? const HomeScreen() : const AuthScreen();
              },
            )
          : IntroScreen(
              done: () {
                settings.introductionScreenVisited = true;
                ref.read(settingsProvider.notifier).notifyListeners();
              },
            ),
    );
  }
}
