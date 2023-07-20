import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/requests/other/other_request.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/complaint_template_message.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

// ignore: must_be_immutable
class OtherRequestScreen extends StatefulWidget {
  static const routeName = 'Other Request Screen';
  OtherRequest? request;
  OtherRequestScreen({
    super.key,
    this.request,
  });

  @override
  State<OtherRequestScreen> createState() => _OtherRequestScreenState();
}

class _OtherRequestScreenState extends State<OtherRequestScreen> {
  final _txtController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    widget.request ??= OtherRequest(userEmail: currentUser.email!);
    final Map<String, dynamic> uiElement = Request.uiElements['Other']!;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GridTileLogo(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    title: 'Other',
                    icon: Icon(
                      uiElement['icon'],
                      size: 50,
                    ),
                    color: theme.colorScheme.background,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _txtController,
                decoration: InputDecoration(
                  hintText: 'Specify the details for the request here',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: _loading
                    ? circularProgressIndicator()
                    : const Icon(Icons.done),
                label: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (widget.request == null || _txtController.text.trim().isEmpty) {
      showMsg(context, 'Please specify the details for the request');
      return;
    }
    widget.request!.reason = _txtController.text.trim();
    setState(() {
      _loading = true;
    });
    await widget.request!.update();
    await widget.request!.fetchApprovers();
    if (context.mounted) {
      setState(() {
        _loading = false;
      });
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
      navigatorPush(
        context,
        ChatScreen(
          chat: widget.request!.chatData,
          initialMsg: MessageData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            from: currentUser.email!,
            createdAt: DateTime.now(),
            txt: otherRequestMessage(widget.request!),
          ),
        ),
      );
    }
  }
}
