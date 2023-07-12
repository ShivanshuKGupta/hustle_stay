import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/state_switch.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/screens/chat/image_preview.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_bottom_bar.dart';

// ignore: must_be_immutable
class ComplaintListItem extends ConsumerStatefulWidget {
  ComplaintListItem({
    super.key,
    required this.complaint,
  });

  ComplaintData complaint;

  @override
  ConsumerState<ComplaintListItem> createState() => _ComplaintListItemState();
}

class _ComplaintListItemState extends ConsumerState<ComplaintListItem>
    with TickerProviderStateMixin {
  final duration = const Duration(milliseconds: 800);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      controller: _controller,
      autoPlay: false,
      effects: const [FadeEffect(begin: 1, end: 0)],
      child: ListTile(
        onTap: () =>
            showComplaintChat(context, widget.complaint, showInfo: _showInfo),
        onLongPress: () => _showInfo(),
        title: Text(widget.complaint.title),
        subtitle: widget.complaint.description == null
            ? null
            : Text(
                widget.complaint.description!,
                overflow: TextOverflow.fade,
                maxLines: 4,
              ),

        /// if no image is associated with the complaint
        /// then I will show the user image who posted that complaint
        /// if the user doesn't has an image then
        /// just an info icon
        leading: widget.complaint.imgUrl == null
            ? UserBuilder(
                email: widget.complaint.from,
                src: Source.cache,
                builder: (ctx, userData) {
                  return const InkWell(
                    child: CircleAvatar(
                      child: Icon(Icons.info_rounded),
                    ),
                  );
                })
            : InkWell(
                child: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(widget.complaint.imgUrl!),
                ),
                onTap: () {
                  navigatorPush(
                    context,
                    ImagePreview(
                      image: CachedNetworkImage(
                          imageUrl: widget.complaint.imgUrl!),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void editMe() async {
    final editedComplaint = await navigatorPush(
      context,
      EditComplaintsPage(
        complaint: widget.complaint,
        deleteMe: deleteMe,
      ),
    );
    if (editedComplaint != null) {
      if (editedComplaint == "deleted") {
        toggleSwitch(ref, complaintBuilderSwitch);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        _controller.animateTo(1);
        Future.delayed(duration, () {
          setState(() {
            widget.complaint = editedComplaint;
          });
          _controller.animateTo(0);
          Future.delayed(duration, () {
            for (int i = ComplaintsBuilder.complaints.length; i-- > 0;) {
              if (ComplaintsBuilder.complaints[i].id == widget.complaint.id) {
                ComplaintsBuilder.complaints[i] = widget.complaint;
                break;
              }
            }
            toggleSwitch(ref, complaintBuilderSwitch);
          });
        });
      }
    }
  }

  Future<bool> deleteMe() async {
    final response = await askUser(
      context,
      'Do you really wish to delete this complaint?',
      yes: true,
      no: true,
    );
    if (response == 'yes') {
      await deleteComplaint(complaint: widget.complaint);
      _controller.animateTo(1);
      Future.delayed(duration, () {
        Future.delayed(duration, () {
          ComplaintsBuilder.complaints
              .removeWhere((element) => element.id == widget.complaint.id);
          toggleSwitch(ref, complaintBuilderSwitch);
          _controller.reset();
        });
      });
      return true;
    }
    return false;
  }

  void _showInfo() {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(widget.complaint.id);
    final DateTime? resolvedAt = widget.complaint.resolvedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(widget.complaint.resolvedAt!);
    Navigator.of(context).push(
      DialogRoute(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            actionsPadding: const EdgeInsets.only(bottom: 15),
            contentPadding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            actionsAlignment: MainAxisAlignment.spaceAround,
            title: Text(widget.complaint.title),
            actions: [
              IconButton(
                onPressed: () => editMe(),
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                onPressed: () async {
                  if (await deleteMe() == true) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.delete_rounded),
              ),
            ],
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.complaint.imgUrl != null)
                  Align(
                    alignment: Alignment.topCenter,
                    child: CachedNetworkImage(
                      imageUrl: widget.complaint.imgUrl!,
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (widget.complaint.description != null &&
                    widget.complaint.description!.isNotEmpty)
                  Text(
                    "Description: ",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                if (widget.complaint.description != null &&
                    widget.complaint.description!.isNotEmpty)
                  Text(widget.complaint.description!),
                Text(
                  "Complainant: ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  widget.complaint.from,
                  textAlign: TextAlign.right,
                ),
                Text(
                  "Complainees: ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text("${widget.complaint.to}"),
                Text(
                  "Category: ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(widget.complaint.category ?? 'other'),
                const Divider(),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      "Created At: ",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      "${ddmmyyyy(createdAt)} ${timeFrom(createdAt)}",
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                if (widget.complaint.resolvedAt != null)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        "Resolved At: ",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        "${ddmmyyyy(resolvedAt!)} ${timeFrom(resolvedAt)}",
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Creates and Navigates you to the approriate Chat Screen based on the complaint
Future<void> showComplaintChat(BuildContext context, ComplaintData complaint,
    {MessageData? initialMsg, void Function()? showInfo}) {
  return navigatorPush<void>(
    context,
    ChatScreen(
      initialMsg: initialMsg,
      bottomBar: ComplaintBottomBar(
        context: context,
        complaint: complaint,
      ),
      chat: ChatData(
        locked: complaint.resolvedAt != null,
        path: "complaints/${complaint.id}",
        owner: complaint.from,
        receivers: complaint.to,
        title: complaint.title,
        description: complaint.description,
      ),
      showInfo: showInfo,
    ),
  );
}
