import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/requests/mess/menu_change_request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/template_messages.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

// ignore: must_be_immutable
class MenuChangeRequestScreen extends StatefulWidget {
  MenuChangeRequest? request;
  MenuChangeRequestScreen({
    super.key,
    this.request,
  });

  @override
  State<MenuChangeRequestScreen> createState() =>
      _MenuChangeRequestScreenState();
}

class _MenuChangeRequestScreenState extends State<MenuChangeRequestScreen> {
  final _txtController = TextEditingController();

  final List<String> options = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  static Set<String> days = {
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  };

  bool _loading = false;

  String? day;

  @override
  void initState() {
    super.initState();
    if (widget.request != null) {
      String reason = widget.request!.reason;
      widget.request!.reason = "";
      if (reason.length >= 3) {
        String str = reason.substring(0, 3);
        if (days.contains(str)) {
          day = str;
          reason = reason.substring(str.length + 1);
        }
        str = reason.split('\n')[0];
        if (options.contains(str)) {
          widget.request!.reason = str;
          reason = reason.substring(str.length + 1);
        }
        _txtController.text = reason;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    widget.request ??=
        MenuChangeRequest(requestingUserEmail: currentUser.email!);
    final Map<String, dynamic> uiElement = widget.request!.uiElement;
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
                    title: 'Menu Change',
                    icon: Icon(
                      uiElement['icon'],
                      size: 50,
                    ),
                    color: theme.colorScheme.background,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SelectOne(
                title: 'Which Day?',
                subtitle: '(optional)',
                allOptions: days..add('None'),
                selectedOption: day ?? 'None',
                onChange: (value) {
                  if (value == 'None') {
                    day = null;
                  } else {
                    day = value;
                  }
                  return true;
                },
              ),
              const SizedBox(height: 20),
              if (options.isNotEmpty)
                SelectOne(
                  title: 'Which Meal?',
                  subtitle: '(optional)',
                  allOptions: (options..add('Other')).toSet(),
                  selectedOption: widget.request!.reason.isEmpty
                      ? 'Other'
                      : widget.request!.reason,
                  onChange: (value) {
                    if (value == 'Other') {
                      widget.request!.reason = '';
                    } else {
                      widget.request!.reason = value;
                    }
                    return true;
                  },
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _txtController,
                decoration: InputDecoration(
                  hintText: 'Please specify the details for the change here',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _txtController.text.trim().isEmpty ? null : _save,
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
    _txtController.text = _txtController.text.trim();
    if (widget.request == null || _txtController.text.isEmpty) {
      showMsg(context, 'Please specify the details for the change');
      return;
    }
    widget.request!.reason =
        "${day == null ? '' : ' $day'} ${widget.request!.reason.isEmpty ? '' : widget.request!.reason}"
            .trim();
    if (widget.request!.reason.isNotEmpty) {
      widget.request!.reason += "\n";
    }
    widget.request!.reason += _txtController.text;
    setState(() {
      _loading = true;
    });
    bool isUpdate = widget.request!.id != 0;
    await widget.request!.update();
    await widget.request!.fetchApprovers();
    if (context.mounted) {
      setState(() {
        _loading = false;
      });
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
      if (!isUpdate) {
        navigatorPush(
          context,
          ChatScreen(
            chat: widget.request!.chatData,
            initialMsg: MessageData(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              from: currentUser.email!,
              createdAt: DateTime.now(),
              txt: messMenuChangeMessage(widget.request!),
            ),
          ),
        );
      }
    }
  }
}
