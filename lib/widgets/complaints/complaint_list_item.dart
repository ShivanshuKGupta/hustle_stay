import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_bottom_bar.dart';

class ComplaintListItem extends StatefulWidget {
  ComplaintListItem({
    super.key,
    required this.complaint,
  });

  ComplaintData complaint;

  @override
  State<ComplaintListItem> createState() => _ComplaintListItemState();
}

class _ComplaintListItemState extends State<ComplaintListItem> {
  bool _animate = false;
  AnimationController? animController;
  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 800);
    return ListTile(
      leading: Icon(
        Icons.info_rounded,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(widget.complaint.title),
      subtitle: widget.complaint.description == null
          ? null
          : Text(
              widget.complaint.description!,
              overflow: TextOverflow.fade,
              maxLines: 4,
            ),
      trailing: IconButton(
          onPressed: () async {
            final editedComplaint = await navigatorPush(
              context,
              EditComplaintsPage(id: widget.complaint.id),
            );
            if (editedComplaint != null) {
              // Animating changes
              setState(() {
                _animate = !_animate;
              });
              Future.delayed(duration, () {
                if (editedComplaint != "deleted") {
                  setState(() {
                    widget.complaint = editedComplaint;
                    _animate = !_animate;
                  });
                } else {
                  // TODO: update the complaints list of this removal of complaint
                }
              });
            }
          },
          icon: const Icon(Icons.edit_rounded)),
      onTap: () => showComplaintChat(context, widget.complaint),
    )
        .animate(target: !_animate ? 1 : 0)
        .fade(begin: 0, end: 1, duration: duration);
  }
}

/// Creates and Navigates you to the approriate Chat Screen based on the complaint
Future<void> showComplaintChat(BuildContext context, ComplaintData complaint,
    {MessageData? initialMsg}) {
  return navigatorPush<void>(
    context,
    ChatScreen(
      initialMsg: initialMsg,
      bottomBar: ComplaintBottomBar(
        context: context,
        complaint: complaint,
      ),
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
