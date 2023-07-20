import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';

class RequestInfo extends StatefulWidget {
  final Map<String, dynamic> uiElement;
  final Request request;
  final Map<String, String> details;
  const RequestInfo(
      {super.key,
      required this.uiElement,
      required this.request,
      required this.details});

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  @override
  Widget build(BuildContext context) {
    final title = widget.request.reason.split(':')[0];
    String subtitle = widget.request.reason.length > title.length + 2
        ? widget.request.reason.substring(title.length + 2).trim()
        : '';
    final theme = Theme.of(context);
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      scrollable: true,
      actionsPadding: const EdgeInsets.only(bottom: 15, top: 10),
      contentPadding: const EdgeInsets.only(
        top: 15,
        left: 20,
        right: 20,
      ),
      content: LayoutBuilder(
        builder: (ctx, constraints) => Column(
          children: [
            Icon(widget.uiElement['icon']),
            Text(
              title,
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            ),
            const Divider(),
            ...widget.details.entries.map(
              (e) => e.key == '-'
                  ? const Divider()
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(
                              "${e.key}:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      // color: Theme.of(context).colorScheme.primary,
                                      ),
                            ),
                            Text(
                              e.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: (widget.request.status != RequestStatus.pending)
          ? [
              const SizedBox(
                height: 10,
              )
            ]
          : [
              if (currentUser.readonly.type == 'student')
                TextButton.icon(
                  onPressed: () async {
                    final response = await askUser(
                        context, 'Do you really want to withdraw this request?',
                        yes: true, no: true);
                    if (response == 'yes') {
                      try {
                        await widget.request.delete();
                      } catch (e) {
                        if (context.mounted) {
                          showMsg(context, e.toString());
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Withdraw'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              if (currentUser.readonly.type != 'student')
                TextButton.icon(
                  onPressed: () async {
                    final response = await askUser(
                        context, 'Do you really want to approve this request?',
                        yes: true, no: true);
                    if (response == 'yes') {
                      try {
                        await widget.request.approve();
                      } catch (e) {
                        if (context.mounted) {
                          showMsg(context, e.toString());
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              if (currentUser.readonly.type != 'student')
                TextButton.icon(
                  onPressed: () async {
                    final response = await askUser(
                        context, 'Do you really want to deny this request?',
                        yes: true, no: true);
                    if (response == 'yes') {
                      try {
                        await widget.request.deny();
                      } catch (e) {
                        if (context.mounted) {
                          showMsg(context, e.toString());
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Deny'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                )
            ],
    );
  }
}
