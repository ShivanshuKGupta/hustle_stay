import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

import '../widgets/complaints/complaints_list.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  Future<ComplaintData?> showAddComplaintPage(BuildContext context) async {
    return await Navigator.of(context).push<ComplaintData>(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: const Text('File a Complaint'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ComplaintForm(
                onSubmit: addComplaint,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ComplaintList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ComplaintData? complaint = await showAddComplaintPage(context);
          print(complaint?.title);
          if (complaint != null) {
            final chat = ChatData(
              path: "complaints/${complaint.id}",
              owner: UserData(email: complaint.from),
              receivers: complaint.to.map((e) => UserData(email: e)).toList(),
              title: complaint.title,
              description: complaint.description,
            );
            setState(() {});
            if (context.mounted) {
              navigatorPush(
                context,
                ChatScreen(
                  chat: chat,
                  initialMsg: MessageData(
                    id: "_",
                    txt:
                        "Hi ${complaint.to}, \n\nI hope you're doing well. I wanted to bring to your attention a concerning issue regarding **${complaint.title}**. ${complaint.description ?? ""}\n\nI kindly request your immediate attention to this matter. Clear communication and updates throughout the process would be greatly appreciated.\n\nThank you for your understanding, and I look forward to a satisfactory resolution.\n\nBest regards, \n${currentUser.name ?? currentUser.email}\n\n---\n\n[Image]",
                    from: currentUser.email!,
                    createdAt: DateTime.now(),
                  ),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
