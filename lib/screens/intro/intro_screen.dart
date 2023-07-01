import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/intro/Intro_requests.dart';
import 'package:hustle_stay/screens/intro/intro_app.dart';
import 'package:hustle_stay/screens/intro/intro_attendance.dart';
import 'package:hustle_stay/screens/intro/intro_complaints.dart';

class IntroScreen extends StatefulWidget {
  final void Function() done;
  const IntroScreen({super.key, required this.done});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late TabController _tabBarController;
  late PageController _pageController;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      Center(child: IntroApp()),
      Center(child: IntroAttendance()),
      Center(child: IntroComplaints()),
      Center(child: IntroRequests()),
    ];
    _pageController = PageController();
    _tabBarController = TabController(length: _pages.length, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 400);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (value) {
                setState(() {
                  _tabBarController.animateTo(value);
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _tabBarController.index == 0
                    ? null
                    : () {
                        final index = _tabBarController.index - 1;
                        _pageController.animateToPage(index,
                            duration: duration, curve: Curves.decelerate);
                      },
                child: const Text('Back'),
              ),
              TabPageSelector(
                borderStyle: BorderStyle.none,
                controller: _tabBarController,
                color: Theme.of(context).colorScheme.inversePrimary,
                selectedColor: Theme.of(context).colorScheme.primary,
              ),
              TextButton(
                onPressed: () {
                  final index = _tabBarController.index + 1;
                  if (index == _tabBarController.length) {
                    widget.done();
                    return;
                  }
                  _pageController.animateToPage(index,
                      duration: duration, curve: Curves.decelerate);
                },
                child: Text(
                    _tabBarController.index == _tabBarController.length - 1
                        ? "Done"
                        : 'Next'),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
