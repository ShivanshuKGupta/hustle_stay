import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat_screen.dart';
import 'package:hustle_stay/tools.dart';

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
                return ListTile(
                  leading: Icon(
                    Icons.info_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(complaint.title),
                  subtitle: complaint.description == null
                      ? null
                      : Text(complaint.description!),
                  onTap: () {
                    navigatorPush(
                      context,
                      ChatScreen(
                        chat: ChatData(
                          path: "complaints/${complaint.id}",
                          owner: UserData(email: complaint.from),
                          receivers: complaint.to
                              .map((e) => UserData(email: e))
                              .toList(),
                          title: complaint.title,
                          description: complaint.description,
                        ),
                      ),
                    );
                  },
                );
              },
              itemCount: complaints.length,
            ),
    );
  }
}
