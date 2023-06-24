import 'package:flutter/material.dart';

import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/screens/complaints/add_complaints_page.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/complaints/complaints_list.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ComplaintList(
        key: UniqueKey(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addComplaint,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  _addComplaint() async {
    ComplaintData? complaint = await Navigator.of(context).push<ComplaintData>(
      MaterialPageRoute(
        builder: (ctx) => const AddComplaintsPage(),
      ),
    );
    if (complaint != null) {
      setState(() {
        complaints.insert(0, complaint);
      });
      if (context.mounted) {
        showComplaintChat(context, complaint);
      }
    }
  }
}
