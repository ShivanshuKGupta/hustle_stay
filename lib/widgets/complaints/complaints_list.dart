import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat_screen.dart';
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
        });
  }
}
