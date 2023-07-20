import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel/hostels.dart';

class ManageHostel extends StatefulWidget {
  const ManageHostel({super.key, required this.hostel});
  final Hostels hostel;
  @override
  State<ManageHostel> createState() => _ManageHostelState();
}

class _ManageHostelState extends State<ManageHostel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(widget.hostel.hostelName)),
    );
  }
}
