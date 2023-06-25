import 'package:flutter/material.dart';

import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/widgets/chat/message_list.dart';
import 'package:hustle_stay/widgets/chat/message_input_field.dart';

import '../../models/message.dart';

class ChatScreen extends StatelessWidget {
  final ChatData chat;
  final MessageData? initialMsg;
  final Widget? bottomBar;

  const ChatScreen({
    super.key,
    required this.chat,
    this.initialMsg,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = ListTile(
      onTap: () {},
      title: Text(chat.title),
      subtitle: chat.description == null
          ? null
          : Text(
              chat.description!,
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
    );
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          bottom: (bottomBar == null)
              ? null
              : PreferredSize(
                  preferredSize: const Size(double.infinity, 40),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: bottomBar!,
                  ),
                ),
          title: titleWidget,
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
                onSubmit: (MessageData msg) async {
                  await addMessage(chat, msg);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
