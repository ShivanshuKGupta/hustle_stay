import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/tools.dart';

class ComplaintList extends StatefulWidget {
  const ComplaintList({super.key});

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchComplaints(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: circularProgressIndicator(
                height: null,
                width: null,
              ),
            );
          }
          List<ComplaintData> complaints = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                final complaint = complaints[index];
                return ListTile(
                  title: Text(complaint.title),
                  subtitle: complaint.description == null
                      ? null
                      : Text(complaint.description!),
                  onTap: () {},
                );
              },
              itemCount: complaints.length,
            ),
          );
        });
  }
}
