import 'package:flutter/material.dart';
import './attendance_screen.dart';
import './login_screen.dart';

enum Names {
  bottomNavigationBarItem,
  screen,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var currentIndex = 2;
  final List<Map> barItems = [
    {
      Names.bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.airport_shuttle_rounded), label: 'Vehicle'),
      Names.screen: HomePage()
    },
    {
      Names.bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.question_answer_rounded), label: 'Complaint'),
      Names.screen: HomePage()
    },
    {
      Names.bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded), label: 'Home'),
      Names.screen: HomePage()
    },
    {
      Names.bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.co_present_rounded), label: 'Attendance'),
      Names.screen: const AttendanceScreen()
    },
    {
      Names.bottomNavigationBarItem: const BottomNavigationBarItem(
          icon: Icon(Icons.question_answer_rounded), label: 'FAQ'),
      Names.screen: HomePage()
    }
  ];
  List<BottomNavigationBarItem> get bottomItems {
    final List<BottomNavigationBarItem> ans = [];
    for (var element in barItems) {
      ans.add(element[Names.bottomNavigationBarItem]);
    }
    return ans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: bottomItems,
        backgroundColor: Colors.black,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        unselectedItemColor: Colors.black45,
        selectedItemColor: Colors.black,
      ),
      backgroundColor: Colors.white70,
      body: barItems[currentIndex][Names.screen],
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            maxRadius: 100,
            backgroundColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Image.network(
                  fit: BoxFit.cover,
                  color: Colors.white,
                  'https://upload.wikimedia.org/wikipedia/en/thumb/d/d8/Indian_Institute_of_Information_Technology%2C_Raichur_Logo.svg/1200px-Indian_Institute_of_Information_Technology%2C_Raichur_Logo.svg.png'),
            ),
          ),
          Text(
            'Hustle Stay',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('Hostel Life, Hustle Life, HustleStay Life'),
          LoginPage()
        ],
      ),
    );
  }
}
