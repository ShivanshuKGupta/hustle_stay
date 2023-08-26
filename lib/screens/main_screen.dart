import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/attendance_screen.dart';
import 'package:hustle_stay/screens/complaints/complaints_screen.dart';
import 'package:hustle_stay/screens/hostel/hostel_screen.dart';
import 'package:hustle_stay/screens/requests/requests_screen.dart';
import 'package:hustle_stay/screens/settings/settings_screen.dart';
import 'package:hustle_stay/screens/vehicle/vehicle_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;

  Future<void> _handleMessage(RemoteMessage message) async {
    final String? path = message.data['path'];
    debugPrint("Clicked Notification path: $path");
    if (path == null) return;
    final parts = path.split('/');
    switch (parts[0]) {
      case 'complaints':
        await _handleComplaintNotification(message);
        return;
      case 'requests':
        await _handleRequestNotification(message);
        return;
      case 'chats':
        await _handleChatNotification(message);
        return;
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title;
    final body = message.notification?.body;
    final data = message.data;
    final String? type = data['type'];
    String txt = "";
    switch (type) {
      case 'message':
        txt = "$title says '$body'";
        break;
      case 'creation':
        txt = "creation: $title $body";
        break;
      case 'deletion':
        txt = "deletion: $title $body";
        break;
      case 'updation':
        txt = "updation: $title $body";
        break;
    }
    showMsg(context, txt);
    if (kDebugMode) {
      await _handleMessage(message);
    }
  }

  /// Sets up fcm handlers (other than background handler)
  void initializeFcmHandlers() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the app is opened from a notification
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: ref.read(settingsProvider).currentPage);
    initializeEverything().onError((error, stackTrace) {
      everythingInitialized.value = null;
      showMsg(context, error.toString());
    });

    firebaseMessaging
        .requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    )
        .then((notificationSettings) {
      if (notificationSettings.authorizationStatus !=
          AuthorizationStatus.authorized) {
        askUser(
          context,
          'The app won\'t be able to send you notifications.',
          description:
              "To fix this try restarting the app or try giving the app notification permission in settings.",
        );
      } else {
        debugPrint('Notification permission granted.');
      }
    });

    initializeFCM().then((value) => initializeFcmHandlers());
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    bool canExit = false;
    int i = 0;
    List<Widget> bodyList = [
      currentUser.type == 'student'
          ? const AttendanceScreen()
          : const HostelScreen(),
      const ComplaintsScreen(),
      const SettingsScreen(),
      const RequestsScreen(),
      if (currentUser.type == 'warden' ||
          currentUser.email == 'vehicle@iiitr.ac.in')
        const VehicleScreen(),
    ];
    if (settings.currentPage >= bodyList.length) {
      settings.currentPage = bodyList.length - 1;
      settingsClass.saveSettings();
    }
    return WillPopScope(
      onWillPop: () async {
        if (canExit) return true;
        showMsg(context, 'Press back once again to exit.');
        canExit = true;
        await Future.delayed(const Duration(seconds: 3)).then((value) => null);
        canExit = false;
        return false;
      },
      child: Scaffold(
          extendBody: true,
          bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 2),
            child: GlassWidget(
              radius: 50,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  // color: colorScheme.onBackground.withOpacity(0.8),
                ),
                child: GNav(
                  selectedIndex: settings.currentPage,
                  onTabChange: (value) {
                    if ((settings.currentPage - value).abs() > 1) {
                      _pageController.jumpToPage(value);
                    } else {
                      _switchPage(value);
                    }
                  },
                  gap: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  tabBackgroundColor: colorScheme.onBackground.withOpacity(0.8),
                  activeColor: colorScheme.inversePrimary,
                  color: colorScheme.onBackground,
                  tabs: [
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.calendar_month_rounded
                          : Icons.calendar_month_outlined,
                      text: 'Attendance',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.info_rounded
                          : Icons.info_outline_rounded,
                      text: 'Complaints',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.person_rounded
                          : Icons.person_outlined,
                      text: 'Profile',
                    ),
                    GButton(
                      icon: settings.currentPage == i++
                          ? Icons.assignment_turned_in_rounded
                          : Icons.assignment_turned_in_outlined,
                      text: 'Requests',
                    ),
                    if (currentUser.type == 'warden' ||
                        currentUser.email == 'vehicle@iiitr.ac.in')
                      GButton(
                        icon: settings.currentPage == i++
                            ? Icons.airport_shuttle_rounded
                            : Icons.airport_shuttle_outlined,
                        text: 'Vehicle',
                      ),
                  ],
                ),
              ),
            ),
          ),
          body: PageView(
            pageSnapping: true,
            controller: _pageController,
            onPageChanged: (value) {
              setState(() => settings.currentPage = value);
              settingsClass.saveSettings();
            },
            children: bodyList,
          )
          // bodyList[settings.currentPage],
          ),
    );
  }

  void _switchPage(int value) {
    _pageController.animateToPage(
      value,
      curve: Curves.decelerate,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _handleComplaintNotification(RemoteMessage message) async {
    final title = message.notification?.title;
    final body = message.notification?.body;
    final data = message.data;
    final String path = data['path'];
    final String? type = data['type'];
    debugPrint("Handling complaint notification of type: $type");
    final parts = path.split('/');
    // parts[0] is equals to 'complaints'
    final complaintID = int.tryParse(parts[1]);
    if (complaintID == null) {
      debugPrint('Complaint id cannot be obtained for notification id: $path');
      return;
    }
    try {
      await fetchComplaint(complaintID);
    } catch (e) {
      // doc doesn't exists in cache
      await loadingIndicator(
        context,
        () async =>
            await fetchComplaint(complaintID, src: Source.serverAndCache),
        'Fetching Complaint $title',
        description: '$body',
      );
    }
    if (type == 'message') {
      // ignore: use_build_context_synchronously
      await showComplaintChat(
        context,
        await fetchComplaint(complaintID),
      );
    } else {
      _switchPage(1); // showing complaints screen
    }
  }

  Future<void> _handleRequestNotification(RemoteMessage message) async {
    final title = message.notification?.title;
    final body = message.notification?.body;
    final data = message.data;
    final String path = data['path'];
    final String? type = data['type'];
    debugPrint("Handling request notification of type: $type");
    final parts = path.split('/');
    // parts[0] is equals to 'requests'
    final requestID = int.tryParse(parts[1]);
    if (requestID == null) {
      debugPrint('Request id cannot be obtained for notification id: $path');
      return;
    }
    if (type == 'message') {
      try {
        await firestore.doc(path).get(const GetOptions(source: Source.cache));
      } catch (e) {
        // doc doesn't exists in cache
        await loadingIndicator(
          context,
          () async => await firestore.doc(path).get(),
          'Fetching Request $title',
          description: '$body',
        );
      }
      final response =
          await firestore.doc(path).get(const GetOptions(source: Source.cache));
      if (response.data() != null) {
        decodeToRequest(response.data()!);
      } else {
        debugPrint('Unable to fetch request from the server');
      }
    } else {
      _switchPage(3); // showing complaints screen
    }
  }

  Future<void> _handleChatNotification(RemoteMessage message) async {
    final data = message.data;
    String path = data['path'];
    final parts = path.split('/');
    final response = await firestore.doc(path).get();
    // ignore: use_build_context_synchronously
    await showChat(context,
        id: parts[1], emails: response.data()!['recipients']);
  }
}
