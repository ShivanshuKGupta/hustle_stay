import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/auth/auth_screen.dart';
import 'package:hustle_stay/screens/intro/intro_screen.dart';
import 'package:hustle_stay/screens/main_screen.dart';
import 'package:hustle_stay/screens/requests/attendance/attendance_request_screen.dart';
import 'package:hustle_stay/screens/requests/mess/mess_request_screen.dart';
import 'package:hustle_stay/screens/requests/other/other_request_screen.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_requests_screen.dart';
import 'package:hustle_stay/tools.dart';
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
  // Correction code
  if (kDebugMode && currentUser.isAdmin) {
    final complaints = (await firestore.collection('complaints').get())
        .docs
        .map((doc) => ComplaintData.load(int.parse(doc.id), doc.data()))
        .toList();
    for (var complaint in complaints) {
      print("Updating ${complaint.id}...");
      await updateComplaint(complaint);
    }
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
    if (settings.autoDarkMode == true) {
      settings.darkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

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
      routes: {
        /// The app switches from Auth Screen to HomeScreen
        /// according to auth state
        '/': (context) => settings.introductionScreenVisited
            ? StreamBuilder(
                stream: auth.authStateChanges(),
                builder: (ctx, user) {
                  if (user.hasData) {
                    return currentUser.email != null
                        ? const MainScreen()
                        : UserBuilder(
                            email: user.data!.email!,
                            loadingWidget: Scaffold(
                              body: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    circularProgressIndicator(),
                                    const Text('Fetching user details'),
                                  ],
                                ),
                              ),
                            ),
                            builder: (context, user) {
                              currentUser = user;
                              return const MainScreen();
                            },
                          );
                  }
                  return const AuthScreen();
                },
              )
            : IntroScreen(
                done: () {
                  settings.introductionScreenVisited = true;
                  ref.read(settingsProvider.notifier).notifyListeners();
                },
              ),
        AttendanceRequestScreen.routeName: (context) =>
            const AttendanceRequestScreen(),
        VehicleRequestScreen.routeName: (context) =>
            const VehicleRequestScreen(),
        MessRequestScreen.routeName: (context) => const MessRequestScreen(),
        OtherRequestScreen.routeName: (context) => OtherRequestScreen(),
      },
    );
  }
}

ValueNotifier<String?> everythingInitialized = ValueNotifier(null);

Future<void> initializeEverything(context) async {
  try {
    everythingInitialized.value = "Updating users";
    await initializeUsers();
    everythingInitialized.value = "Updating complaints";
    await initializeComplaints();
    // everythingInitialized.value = "Initializing requests";
  } catch (e) {
    showMsg(context, e.toString());
  }
  everythingInitialized.value = null;
}
