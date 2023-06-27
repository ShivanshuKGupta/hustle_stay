import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/widgets/chat/call_button.dart';
import 'package:hustle_stay/widgets/chat/message_input_field.dart';
import 'package:hustle_stay/widgets/chat/message_list.dart';

class ChatScreen extends StatelessWidget {
  final ChatData chat;
  final MessageData? initialMsg;
  final Widget? bottomBar;
  final void Function()? showInfo;

  const ChatScreen({
    super.key,
    required this.chat,
    this.initialMsg,
    this.bottomBar,
    this.showInfo,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = InkWell(
      onTap: showInfo,
      child: Text(
        chat.title,
        overflow: TextOverflow.fade,
        maxLines: 2,
      ),
    );

    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          actions: [
            CallButton(emails: chat.receivers)
                .animate()
                .fade(duration: const Duration(seconds: 1)),
          ],
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
