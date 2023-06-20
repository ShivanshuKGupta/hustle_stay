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

  final _msgTxtBox = TextEditingController();

  void submit(context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _msgTxtBox.text = "";
    try {
      await widget.onSubmit(
        MessageData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    DialogRoute<void>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        actionsAlignment: MainAxisAlignment.center,
                        scrollable: true,
                        actionsPadding: const EdgeInsets.all(10),
                        buttonPadding: const EdgeInsets.all(20),
                        actions: [
                          IconButton(
                            iconSize: 30,
                            onPressed: () {
                              showMsg(context, "In development...");
                            },
                            icon: const Icon(Icons.image_rounded),
                          ),
                          IconButton(
                            iconSize: 30,
                            onPressed: () {
                              showMsg(context, "In development...");
                            },
                            icon: const Icon(Icons.camera_alt_rounded),
                          ),
                          IconButton(
                            iconSize: 30,
                            onPressed: () {
                              showMsg(context, "In development...");
                            },
                            icon: const Icon(Icons.poll_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                color: Theme.of(context).colorScheme.primary,
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
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
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
                  onPressed: makeTitle,
                  icon: const Icon(Icons.title_rounded),
                ),
                IconButton(
                  onPressed: quote,
                  icon: const Icon(Icons.format_quote_rounded),
                ),
                IconButton(
                  onPressed: codeBlock,
                  icon: const Icon(Icons.code_rounded),
                ),
                IconButton(
                  onPressed: showLinkBox,
                  icon: const Icon(Icons.link_rounded),
                ),
                IconButton(
                  onPressed: strikethrough,
                  icon: const Icon(Icons.format_strikethrough_rounded),
                ),
                IconButton(
                  onPressed: addHrLine,
                  icon: const Icon(Icons.horizontal_rule_rounded),
                ),
                IconButton(
                  onPressed: unorderedList,
                  icon: const Icon(Icons.format_list_bulleted_outlined),
                ),
                IconButton(
                  onPressed: orderedList,
                  icon: const Icon(Icons.format_list_numbered_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget contextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      buttonItems.addAll(
        [
          ContextMenuButtonItem(
            label: 'Bold',
            onPressed: () {
              ContextMenuController.removeAny();
              bold();
            },
          ),
          ContextMenuButtonItem(
            label: 'Italic',
            onPressed: () {
              ContextMenuController.removeAny();
              italic();
            },
          ),
          ContextMenuButtonItem(
            label: 'Strikethrough',
            onPressed: () {
              ContextMenuController.removeAny();
              strikethrough();
            },
          ),
          ContextMenuButtonItem(
            label: 'Quote',
            onPressed: () {
              ContextMenuController.removeAny();
              quote();
            },
          ),
          ContextMenuButtonItem(
            label: 'Block',
            onPressed: () {
              ContextMenuController.removeAny();
              quote();
            },
          ),
          ContextMenuButtonItem(
            label: 'Make Title',
            onPressed: () {
              ContextMenuController.removeAny();
              makeTitle();
            },
          ),
        ],
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
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
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}~~${_msgTxtBox.selection.textInside(_msgTxtBox.text)}~~${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void unorderedList() {
    Navigator.of(context).push(
      DialogRoute(
        context: context,
        builder: (ctx) => const AlertDialog(
          content: Text(
              "To make an unordered list, follow the below format:\n\n# Heading\n\n- List item 1.\n- List Item 2.\n- List Item 3.\n\n'-' can also be replaced by '*'"),
        ),
      ),
    );
  }

  void orderedList() {
    Navigator.of(context).push(
      DialogRoute(
        context: context,
        builder: (ctx) => const AlertDialog(
          content: Text(
              'To make an ordered list, follow the below format:\n\n# Heading\n\n1. List item 1.\n1. List Item 2.\n1. List Item 3.'),
        ),
      ),
    );
  }

  void makeTitle() {
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      _msgTxtBox.text =
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}\n\n# ${_msgTxtBox.selection.textInside(_msgTxtBox.text)}\n\n${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void quote() {
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      _msgTxtBox.text =
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}\n> ${_msgTxtBox.selection.textInside(_msgTxtBox.text)}\n${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void codeBlock() {
    if (_msgTxtBox.selection.end - _msgTxtBox.selection.start > 0) {
      _msgTxtBox.text =
          "${_msgTxtBox.selection.textBefore(_msgTxtBox.text)}```${_msgTxtBox.selection.textInside(_msgTxtBox.text)}```${_msgTxtBox.selection.textAfter(_msgTxtBox.text)}";
    }
  }

  void showLinkBox() {
    Navigator.of(context).push(
      DialogRoute(
        context: context,
        builder: (ctx) {
          String url = "";
          return AlertDialog(
            content: TextField(
              maxLines: null,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                  label: Text('Enter your link here'),
                  hintText: "https://www.google.com"),
              autocorrect: false,
              onChanged: (value) {
                url = value;
              },
              onSubmitted: (value) {
                addLink(value);
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  addLink(url);
                  Navigator.of(context).pop();
                },
                child: const Text('Insert'),
              ),
            ],
            titlePadding: const EdgeInsets.all(0),
            actionsPadding: const EdgeInsets.only(bottom: 0, right: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          );
        },
      ),
    );
  }

  void addLink(String url) {
    if (!url.startsWith("www.")) url = "www.$url";
    url = url.replaceAll(" ", '');
    var cursorPos = _msgTxtBox.selection.base.offset;
    if (cursorPos == -1) {
      _msgTxtBox.text = url;
      return;
    }
    String prefixText = _msgTxtBox.text.substring(0, cursorPos);
    String suffixText = _msgTxtBox.text.substring(cursorPos);
    int length = url.length + 2;
    _msgTxtBox.text = "$prefixText $url $suffixText";

    _msgTxtBox.selection = TextSelection(
      baseOffset: cursorPos + length,
      extentOffset: cursorPos + length,
    );
  }

  void addHrLine() {
    var cursorPos = _msgTxtBox.selection.base.offset;
    if (cursorPos == -1) {
      _msgTxtBox.text = "---\n\n";
      return;
    }
    String prefixText = _msgTxtBox.text.substring(0, cursorPos);
    String suffixText = _msgTxtBox.text.substring(cursorPos);
    String iCode = '\n\n---\n\n';
    int length = iCode.length;
    _msgTxtBox.text = prefixText + iCode + suffixText;

    _msgTxtBox.selection = TextSelection(
      baseOffset: cursorPos + length,
      extentOffset: cursorPos + length,
    );
  }
}
