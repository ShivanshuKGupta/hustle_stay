import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/message.dart';

import 'package:hustle_stay/models/chat.dart';

class MessageList extends StatefulWidget {
  ChatData chat;
  MessageList({super.key, required this.chat});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    // TODO: add more functionality like edit a message and send messages in reference to other messages
    final store = FirebaseFirestore.instance;
    return StreamBuilder(
      stream: store.collection("${widget.chat.path}/chat").snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: circularProgressIndicator());
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.size == 0) {
          return Center(
            child: Text(
              'Send your first message',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        widget.chat.messages =
            snapshot.data!.docs.map((e) => MessageData.load(e.data())).toList();
        widget.chat.messages = widget.chat.messages.reversed.toList();
        return ListView.separated(
          reverse: true,
          shrinkWrap: true,
          separatorBuilder: (ctx, index) {
            return SizedBox(
              height: index == widget.chat.messages.length - 1 ||
                      widget.chat.messages[index + 1].from !=
                          widget.chat.messages[index].from
                  ? 10
                  : 1,
            );
          },
          itemBuilder: (ctx, index) {
            final currentMsg = widget.chat.messages[index];
            return Message(
              msg: currentMsg,
              last: index == 0 ||
                  widget.chat.messages[index - 1].from != currentMsg.from,
              first: index == widget.chat.messages.length - 1 ||
                  widget.chat.messages[index + 1].from != currentMsg.from,
              msgAlignment: currentMsg.from == currentUser.email,
            );
          },
          itemCount: widget.chat.messages.length,
        );
      },
    );
  }
}
