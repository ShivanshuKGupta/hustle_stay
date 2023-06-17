import 'package:flutter/material.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';

class MessageInputField extends StatelessWidget {
  MessageInputField({super.key, required this.onSubmit});

  final Future<void> Function(MessageData msg) onSubmit;

  final _formKey = GlobalKey<FormState>();

  String txt = "";

  final _msgTxtBox = TextEditingController();

  void submit(context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _msgTxtBox.text = "";
    try {
      await onSubmit(
        MessageData(
          txt: txt,
          from: currentUser.email!,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      showMsg(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showMsg(context, "Show a tool bar with multiple buttons");
            },
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          Expanded(
            child: TextFormField(
              controller: _msgTxtBox,
              validator: Validate.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                hintText: "Enter your message here",
              ),
              onSaved: (value) => txt = value!.trim(),
            ),
          ),
          IconButton(
            onPressed: () => submit(context),
            icon: const Icon(Icons.send_rounded),
          )
        ],
      ),
    );
  }
}
