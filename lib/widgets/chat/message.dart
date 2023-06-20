import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hustle_stay/models/chat.dart';

import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:url_launcher/url_launcher.dart';

class Message extends StatelessWidget {
  final MessageData msg;
  final ChatData chat;
  final bool first, last;
  final bool msgAlignment;

  const Message({
    super.key,
    required this.msg,
    required this.first,
    required this.last,
    required this.msgAlignment,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    double r = 15;
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment:
          msgAlignment ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showMsgInfo(context, msg);
          },
          child: Container(
            width: size.width * 3 / 4,
            padding: const EdgeInsets.only(left: 5, right: 5),
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(first && msgAlignment ? r : 0),
                topRight: Radius.circular(first && !msgAlignment ? r : 0),
                bottomLeft: Radius.circular(last ? r : 0),
                bottomRight: Radius.circular(last ? r : 0),
              ),
              color: msgAlignment
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (first)
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, left: 1, top: 2),
                    child: Text(
                      msg.from,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                MarkdownBody(
                  fitContent: true,
                  data: msg.txt,
                  selectable: true,
                  onTapText: () => showMsgInfo(context, msg),
                  onTapLink: (text, href, title) {
                    if (href != null) launchUrl(Uri.parse(href));
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 5.0, left: 5, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${msg.createdAt.hour}:${msg.createdAt.minute}",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  showMsgInfo(context, MessageData msg) {
    Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          scrollable: true,
          actionsPadding: const EdgeInsets.only(bottom: 15, top: 10),
          contentPadding: const EdgeInsets.only(top: 15, left: 20, right: 20),
          content: Column(
            children: [
              Text(msg.txt),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "From:",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        // color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    msg.from,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Created At:",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        // color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    "${msg.createdAt.year}-${msg.createdAt.month}-${msg.createdAt.day} | ${msg.createdAt.hour}hr:${msg.createdAt.minute}min:${msg.createdAt.second}sec",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              if (msg.modifiedAt != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Modified At:",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          // color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      "${msg.modifiedAt!.year}-${msg.modifiedAt!.month}-${msg.modifiedAt!.day} | ${msg.modifiedAt!.hour}hr:${msg.modifiedAt!.minute}min:${msg.modifiedAt!.second}sec",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            IconButton(
              iconSize: 30,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: msg.txt));
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showMsg(context, "Copied");
                }
              },
              icon: const Icon(Icons.copy_rounded),
            ),
            if (msg.from == currentUser.email)
              IconButton(
                iconSize: 30,
                onPressed: () async {
                  Navigator.of(context).pop();
                  showMsg(context,
                      "Editing is not allowed as per the rules of the institute.");
                },
                icon: const Icon(Icons.edit_rounded),
              ),
            if (msg.from == currentUser.email)
              IconButton(
                iconSize: 30,
                onPressed: () async {
                  try {
                    await deleteMessage(chat, msg);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showMsg(context, "Message Deleted Successfully");
                    }
                  } catch (e) {
                    showMsg(context, e.toString());
                  }
                },
                icon: const Icon(Icons.delete_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
