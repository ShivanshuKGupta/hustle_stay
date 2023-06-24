import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_bottom_bar.dart';

class ComplaintListItem extends StatelessWidget {
  const ComplaintListItem({
    super.key,
    required this.complaint,
  });

  final ComplaintData complaint;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.info_rounded,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(complaint.title),
      subtitle:
          complaint.description == null ? null : Text(complaint.description!),
      onTap: () => showComplaintChat(context, complaint),
    );
  }
}

/// Creates and Navigates you to the approriate Chat Screen based on the complaint
Future<void> showComplaintChat(BuildContext context, ComplaintData complaint) {
  return navigatorPush<void>(
    context,
    ChatScreen(
      bottomBar: ComplaintBottomBar(context: context),
      chat: ChatData(
        path: "complaints/${complaint.id}",
        owner: UserData(email: complaint.from),
        receivers: complaint.to.map((e) => UserData(email: e)).toList(),
        title: complaint.title,
        description: complaint.description,
      ),
    ),
  );
}
