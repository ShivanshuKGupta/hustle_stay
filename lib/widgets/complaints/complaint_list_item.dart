import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/complaint_list.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_bottom_bar.dart';

class ComplaintListItem extends ConsumerStatefulWidget {
  ComplaintListItem({
    super.key,
    required this.complaint,
  });

  ComplaintData complaint;

  @override
  ConsumerState<ComplaintListItem> createState() => _ComplaintListItemState();
}

class _ComplaintListItemState extends ConsumerState<ComplaintListItem> {
  bool _animate = false;
  AnimationController? animController;
  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 800);
    return ListTile(
      key: ValueKey(widget.complaint.id),
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
              Future.delayed(duration, () {
                if (editedComplaint == "deleted") {
                  ref
                      .read(complaintsList.notifier)
                      .removeComplaint(widget.complaint);
                } else {
                  // Animating changes
                  setState(() {
                    _animate = !_animate;
                  });
                  setState(() {
                    widget.complaint = editedComplaint;
                    _animate = !_animate;
                  });
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
