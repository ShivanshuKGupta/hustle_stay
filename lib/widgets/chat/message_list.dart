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

        widget.chat.messages = snapshot.data!.docs
            .map((e) => MessageData.load(e.id, e.data()))
            .toList();
        widget.chat.messages = widget.chat.messages.reversed.toList();

        return ListView.separated(
          reverse: true,
          shrinkWrap: true,
          separatorBuilder: (ctx, index) {
            final msg = widget.chat.messages[index];
            DateTime createdAt = msg.createdAt;
            final nextMsg = widget.chat.messages[index + 1];

            if (!_sameDay(nextMsg.createdAt, msg.createdAt)) {
              return _dateWidget(createdAt);
            }

            return SizedBox(
              height: nextMsg.from != msg.from ||
                      !_sameDay(msg.createdAt, nextMsg.createdAt)
                  ? 10
                  : 1,
            );
          },
          itemBuilder: (ctx, index) {
            final msg = widget.chat.messages[index];
            final nextMsg = index == widget.chat.messages.length - 1
                ? null
                : widget.chat.messages[index + 1];
            final preMsg = index == 0 ? null : widget.chat.messages[index - 1];
            final first = nextMsg == null ||
                nextMsg.from != msg.from ||
                !_sameDay(msg.createdAt, nextMsg.createdAt);
            return Message(
              chat: widget.chat,
              msg: msg,
              last: preMsg == null ||
                  preMsg.from != msg.from ||
                  !_sameDay(msg.createdAt, preMsg.createdAt),
              first: first,
              msgAlignment: msg.from == currentUser.email,
            );
          },
          itemCount: widget.chat.messages.length,
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return !(a.day != b.day || a.month != b.month || a.year != b.year);
  }

  Widget _dateWidget(DateTime createdAt) {
    return Align(
      heightFactor: 1.25,
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: Theme.of(context).colorScheme.primary,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${createdAt.day}-${createdAt.month}-${createdAt.year}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          )),
    );
  }
}
