import 'package:flutter/material.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';

class MessageInputField extends StatefulWidget {
  MessageInputField({super.key, required this.onSubmit});

  final Future<void> Function(MessageData msg) onSubmit;

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final _formKey = GlobalKey<FormState>();

  String txt = "";

  bool expanded = false;

  final _msgTxtBox = TextEditingController();

  void submit(context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _msgTxtBox.text = "";
    try {
      await widget.onSubmit(
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expanded)
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        expanded = false;
                      });
                    },
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  IconButton(
                    onPressed: bold,
                    iconSize: 25,
                    icon: const Icon(Icons.format_bold_rounded),
                  ),
                  IconButton(
                    onPressed: italic,
                    icon: const Icon(Icons.format_italic_rounded),
                  ),
                  IconButton(
                    onPressed: strikethrough,
                    icon: const Icon(Icons.format_strikethrough_rounded),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.title),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.image_rounded),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.link_rounded),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.email_rounded),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.code_rounded),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.format_list_bulleted),
                  ),
                  IconButton(
                    onPressed: addImage,
                    icon: const Icon(Icons.format_list_numbered_rounded),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              if (!expanded)
                IconButton(
                  onPressed: () {
                    setState(() {
                      expanded = true;
                    });
                  },
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
              Expanded(
                child: TextFormField(
                  key: GlobalKey(),
                  maxLines: 10,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  contextMenuBuilder: contextMenuBuilder,
                  controller: _msgTxtBox,
                  validator: Validate.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
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
        ],
      ),
    );
  }

  void bold() {
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      _msgTxtBox.text =
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}**${_msgTxtBox.selection.textInside(_msgTxtBox.text)}**${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void italic() {
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      _msgTxtBox.text =
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}*${_msgTxtBox.selection.textInside(_msgTxtBox.text)}*${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void strikethrough() {
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      _msgTxtBox.text =
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}~${_msgTxtBox.selection.textInside(_msgTxtBox.text)}~${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void addImage() {
    showMsg(context, "TODO: in development");
  }

  Widget contextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      buttonItems.add(
        ContextMenuButtonItem(
          label: 'Bold',
          onPressed: () {
            ContextMenuController.removeAny();
            bold();
          },
        ),
      );
      buttonItems.add(
        ContextMenuButtonItem(
          label: 'Italic',
          onPressed: () {
            ContextMenuController.removeAny();
            italic();
          },
        ),
      );
      buttonItems.add(
        ContextMenuButtonItem(
          label: 'more will be added',
          onPressed: () {
            ContextMenuController.removeAny();
            showMsg(context, 'TODO: add more like underline etc.');
          },
        ),
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }
}
