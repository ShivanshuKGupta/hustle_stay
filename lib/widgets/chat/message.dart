import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/tools.dart';
import 'package:url_launcher/url_launcher.dart';

class Message extends StatelessWidget {
  final MessageData msg;
  final bool first, last;
  final bool msgAlignment;

  const Message({
    super.key,
    required this.msg,
    required this.first,
    required this.last,
    required this.msgAlignment,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: add from whom it came and createdAt on the message
    // TODO: add a nice chat shape based on whether it the first or last
    double r = 15;
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment:
          msgAlignment ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
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
                onTapText: () {
                  Navigator.of(context).push(
                    DialogRoute<void>(
                      context: context,
                      builder: (BuildContext context) => const AlertDialog(
                          title: Text('You clicked a message')),
                    ),
                  );
                },
                onTapLink: (text, href, title) {
                  if (href != null) launchUrl(Uri.parse(href));
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0, left: 5, bottom: 2),
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
      ],
    );
  }
}
