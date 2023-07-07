import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

class ResolvedComplaintsScreen extends StatelessWidget {
  const ResolvedComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolved Complaints')),
      body: FutureBuilder(
        future: fetchComplaints(resolved: true),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            showMsg(context, snapshot.error.toString());
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return Center(child: circularProgressIndicator());
          }
          final complaints = snapshot.data!;
          return complaints.isEmpty
              ? Center(
                  child: Text(
                    'All clear✨',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemBuilder: (ctx, index) {
                    final complaint = complaints[index];
                    return ComplaintListItem(
                      complaint: complaint,
                    );
                  },
                  itemCount: complaints.length,
                );
        },
      ),
    );
  }
}
