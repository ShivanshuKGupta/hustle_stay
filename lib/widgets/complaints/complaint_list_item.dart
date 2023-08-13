import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/state_switch.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_bottom_bar.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

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
        onTap: () async {
          await showComplaintChat(context, widget.complaint,
              showInfo: _showComplaintInfo);
          setState(() {});
        },
        onLongPress: () => _showComplaintInfo(),
        title: Text(widget.complaint.title.replaceAll('_', ' ')),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.complaint.description != null)
              Text(
                widget.complaint.description!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (widget.complaint.deletedAt != null)
              Text(
                'Deleted at: ${ddmmyyyy(widget.complaint.deletedAt!)} ${timeFrom(widget.complaint.deletedAt!)}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.red,
                    ),
              ),
            if (widget.complaint.resolvedAt != null)
              Text(
                'Resolved at: ${ddmmyyyy(DateTime.fromMillisecondsSinceEpoch(widget.complaint.resolvedAt!))} ${timeFrom(DateTime.fromMillisecondsSinceEpoch(widget.complaint.resolvedAt!))}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
          ],
        ),
        leading: CategoryBuilder(
          id: widget.complaint.category ?? 'Other',
          builder: (ctx, category) => Stack(
            children: [
              // Positioned(
              //   right: 0,
              //   top: 0,
              //   child: CacheBuilder(
              //       loadingWidget: AnimateIcon(
              //         height: 15,
              //         width: 15,
              //         color: Colors.blue.withOpacity(0.1),
              //         onTap: () {},
              //         iconType: IconType.continueAnimation,
              //         animateIcon: AnimateIcons.loading7,
              //       ),
              //       builder: (ctx, msg) {
              //         if (msg == null ||
              //             msg.readBy.contains(currentUser.email!)) {
              //           return Container();
              //         }
              //         return AnimateIcon(
              //           height: 15,
              //           width: 15,
              //           color: Colors.red,
              //           onTap: () {},
              //           iconType: IconType.continueAnimation,
              //           animateIcon: AnimateIcons.bell,
              //         );
              //       },
              //       provider: ({Source? src}) async {
              //         return await fetchLastMessage(
              //           "complaints/${widget.complaint.id}",
              //           src: src,
              //         );
              //       }),
              // ),
              CircleAvatar(
                backgroundColor: category.color.withOpacity(0.2),
                child: Icon(
                  category.icon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void editMe() async {
    final editedComplaint = await navigatorPush(
      context,
      ComplaintForm(
        complaint: widget.complaint,
        deleteMe: deleteMe,
      ),
    );
    if (editedComplaint != null) {
      if (editedComplaint == "deleted") {
        toggleSwitch(ref, complaintBuilderSwitch);
        // ignore: use_build_context_synchronously
        // Navigator.of(context).pop();
      } else {
        // ignore: use_build_context_synchronously
        // Navigator.of(context).pop();
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
      'Do you really wish to ${widget.complaint.deletedAt == null ? "delete" : "restore"} this complaint?',
      yes: true,
      no: true,
    );
    if (response == 'yes') {
      await deleteComplaint(widget.complaint);
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

  void _showComplaintInfo() {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(widget.complaint.id);
    final modifiedAt =
        DateTime.fromMillisecondsSinceEpoch(widget.complaint.modifiedAt);
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
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.complaint.title.replaceAll('_', ' ')),
                if (widget.complaint.description != null &&
                    widget.complaint.description!.isNotEmpty)
                  Text(
                    widget.complaint.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
            actions: [
              if (currentUser.email == widget.complaint.from ||
                  currentUser.permissions.complaints.update == true)
                IconButton(
                  onPressed: () => editMe(),
                  icon: const Icon(Icons.edit_rounded),
                ),
              if (currentUser.email == widget.complaint.from ||
                  currentUser.permissions.complaints.delete == true)
                IconButton(
                  onPressed: () async {
                    if (await deleteMe() == true) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(
                    widget.complaint.deletedAt == null
                        ? Icons.delete_rounded
                        : Icons.restore_from_trash_rounded,
                  ),
                ),
            ],
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                // Text(
                //   "Category: ",
                //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
                //         color: Theme.of(context).colorScheme.primary,
                //       ),
                // ),
                // Text("${widget.complaint.category}"),
                Text(
                  "Scope: ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(widget.complaint.scope.name),
                const Divider(),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      "Created At: ",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      "${ddmmyyyy(createdAt)} ${timeFrom(createdAt)}",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      "Last Modified At: ",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      "${ddmmyyyy(modifiedAt)} ${timeFrom(modifiedAt)}",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (widget.complaint.resolvedAt != null)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        "Resolved At: ",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        "${ddmmyyyy(resolvedAt!)} ${timeFrom(resolvedAt)}",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                else if (widget.complaint.deletedAt != null)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        "Deleted At: ",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.red,
                            ),
                      ),
                      Text(
                        "${ddmmyyyy(widget.complaint.deletedAt!)} ${timeFrom(widget.complaint.deletedAt!)}",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  Text(
                    "This request is pending...",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
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
        locked: complaint.resolvedAt != null || complaint.deletedAt != null,
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
