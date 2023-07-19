import 'package:flutter/material.dart';

class ManageHostel extends StatefulWidget {
  const ManageHostel({super.key});

  @override
  State<ManageHostel> createState() => _ManageHostelState();
}

class _ManageHostelState extends State<ManageHostel> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hostel & Attendance page'),
      ),
    );
  }
}
