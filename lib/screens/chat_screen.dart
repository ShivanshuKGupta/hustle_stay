import 'package:flutter/material.dart';

import 'package:hustle_stay/models/chat.dart';
import 'package:hustle_stay/widgets/chat/message_list.dart';
import 'package:hustle_stay/widgets/chat/message_input_field.dart';

import '../models/message.dart';

class ChatScreen extends StatelessWidget {
  final ChatData chat;
  final MessageData? initialMsg;
  const ChatScreen({super.key, required this.chat, this.initialMsg});

  Future<void> sendMessage(MessageData msg) async {
    await addMessage(chat, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(chat.title),
          subtitle: chat.description == null
              ? null
              : Text(
                  chat.description!,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(chat: chat),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0, left: 5, top: 5),
            child: MessageInputField(
              initialValue: initialMsg != null ? initialMsg!.txt : "",
              onSubmit: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
