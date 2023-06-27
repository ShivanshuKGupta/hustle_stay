import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/screens/complaints/complaints_screen.dart';
import 'package:hustle_stay/tools.dart';

class ResolvedComplaintsScreen extends StatelessWidget {
  const ResolvedComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolved Complaints')),
      body: FutureBuilder(
          future: fetchComplaints(resolved: true),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: circularProgressIndicator());
            }
            final complaints = snapshot.data!;
            return complaintsListWidget(
              context,
              complaints,
              MediaQuery.of(context),
              const Duration(milliseconds: 500),
            );
          }),
    );
  }
}
