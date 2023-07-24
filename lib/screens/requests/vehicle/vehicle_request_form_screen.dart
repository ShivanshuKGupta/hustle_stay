import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/requests/vehicle/vehicle_request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/template_messages.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

// ignore: must_be_immutable
class VehicleRequestFormScreen extends StatefulWidget {
  final String title;
  final Icon icon;
  List<String> reasonOptions;
  VehicleRequest? request;
  VehicleRequestFormScreen({
    super.key,
    required this.title,
    required this.icon,
    this.request,
    required this.reasonOptions,
  });

  @override
  State<VehicleRequestFormScreen> createState() =>
      _VehicleRequestFormScreenState();
}

class _VehicleRequestFormScreenState extends State<VehicleRequestFormScreen> {
  final _txtController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.request != null &&
        !widget.reasonOptions.contains(widget.request!.reason)) {
      _txtController.text = widget.request!.reason;
      widget.request!.reason = 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    widget.request ??= VehicleRequest(
        requestingUserEmail: currentUser.email!, title: widget.title);
    widget.reasonOptions = widget.reasonOptions.map((e) => e).toList();
    TimeOfDay? time = widget.request!.dateTime == null
        ? null
        : TimeOfDay.fromDateTime(widget.request!.dateTime!);
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
                    title: widget.title.replaceAll('_', ' '),
                    icon: widget.icon,
                    color: theme.colorScheme.background,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: () async {
                  final dateTime = widget.request!.dateTime;
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dateTime ?? now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 1),
                  );
                  if (date != null) {
                    setState(() {
                      widget.request!.dateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        dateTime == null ? now.hour : dateTime.hour,
                        dateTime == null ? now.minute : dateTime.minute,
                        dateTime == null ? now.second : dateTime.second,
                      );
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(widget.request!.dateTime == null
                    ? 'Which day?'
                    : 'on ${ddmmyyyy(widget.request!.dateTime!)}'),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final dateTime = widget.request!.dateTime ?? now;
                  time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(dateTime),
                  );
                  if (time != null) {
                    setState(() {
                      widget.request!.dateTime = DateTime(
                          dateTime.year,
                          dateTime.month,
                          dateTime.day,
                          time!.hour,
                          time!.minute,
                          0);
                    });
                  }
                },
                icon: const Icon(Icons.access_time_rounded),
                label: Text(time == null
                    ? 'When?'
                    : 'at ${timeFrom(widget.request!.dateTime!)}'),
              ),
              const SizedBox(height: 20),
              if (widget.reasonOptions.isNotEmpty)
                SelectOne(
                  title: 'Reason?',
                  subtitle: '(optional)',
                  allOptions: (widget.reasonOptions..add('Other')).toSet(),
                  selectedOption: widget.request!.reason,
                  onChange: (value) {
                    setState(() {
                      widget.request!.reason = value;
                    });
                    return true;
                  },
                ),
              if (widget.request!.reason == 'Other' ||
                  widget.reasonOptions.isEmpty)
                TextFormField(
                  controller: _txtController,
                  decoration: InputDecoration(
                    hintText: widget.reasonOptions.isEmpty
                        ? 'Reason? (optional)'
                        : 'Please specify',
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
                onPressed:
                    widget.request == null || widget.request!.dateTime == null
                        ? null
                        : _save,
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
    if (widget.request == null || widget.request!.dateTime == null) {
      showMsg(context, 'Please specifiy a date and time');
      return;
    }
    if (widget.request!.reason == 'Other' || widget.reasonOptions.isEmpty) {
      widget.request!.reason = _txtController.text.trim();
    }
    bool isAnUpdate = widget.request!.id != 0;
    setState(() {
      _loading = true;
    });
    final dateTime = widget.request!.dateTime!;
    try {
      await widget.request!.update(
          chosenExpiryDate:
              DateTime(dateTime.year, dateTime.month, dateTime.day + 7));
      await widget.request!.fetchApprovers();
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }
    if (context.mounted) {
      setState(() {
        _loading = false;
      });
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
      if (!isAnUpdate) {
        navigatorPush(
          context,
          ChatScreen(
            chat: widget.request!.chatData,
            initialMsg: MessageData(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              from: currentUser.email!,
              createdAt: DateTime.now(),
              txt: vanRequestTemplateMessage(widget.request!, widget.title),
            ),
          ),
        );
      }
    }
  }
}
