import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

/// The widget contanining list of complaints
/// shown on the complaints screen
class ComplaintList extends StatefulWidget {
  const ComplaintList({super.key});

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

/// This contains fetched complaints which are mostly upto date
List<ComplaintData> complaints = [];

class _ComplaintListState extends State<ComplaintList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchComplaints(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return FutureBuilder(
                future: fetchComplaints(src: Source.cache),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    complaints = snapshot.data!;
                  } else if (complaints.isEmpty) {
                    return Center(
                      child:
                          circularProgressIndicator(height: null, width: null),
                    );
                  }
                  return complaintsList();
                });
          }
          complaints = snapshot.data!;
          return complaintsList();
        });
  }

  /// Just a list view with a placeholder when there is no item in the list
  Widget complaintsList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: complaints.isEmpty
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No Complaints ✨',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                final complaint = complaints[index];
                return ComplaintListItem(complaint: complaint);
              },
              itemCount: complaints.length,
            ),
    );
  }
}
