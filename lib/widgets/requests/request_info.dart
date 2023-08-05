import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/mess/menu_change_request.dart';
import 'package:hustle_stay/models/requests/other/other_request.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/requests/vehicle/vehicle_request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/requests/mess/menu_change_screen.dart';
import 'package:hustle_stay/screens/requests/other/other_request_screen.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_request_form_screen.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_requests_screen.dart';
import 'package:hustle_stay/tools.dart';

class RequestInfo extends StatefulWidget {
  final Request request;
  final Map<String, String> details;
  const RequestInfo({super.key, required this.request, required this.details});

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  @override
  Widget build(BuildContext context) {
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
            Icon(widget.request.uiElement['icon']),
            Text(
              widget.request.type.replaceAll('_', ' '),
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              widget.request.reason,
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
      actions: [
        if ((widget.request.requestingUserEmail == currentUser.email &&
                widget.request.status == RequestStatus.pending) ||
            currentUser.permissions.requests.update == true)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              final request = decodeToRequest(widget.request.encode());
              Widget page = Scaffold(
                appBar: AppBar(),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'To edit requests of type \'${request.type.replaceAll('_', ' ')}\', you may have to use some other feature in the app.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
              if (request is VehicleRequest) {
                page = VehicleRequestFormScreen(
                  request: request,
                  title: request.title,
                  icon: Icon(allVehicleRequestsData[request.title]['icon']),
                  reasonOptions: allVehicleRequestsData[request.title]
                      ['reasonOptions'],
                );
              } else if (request is MenuChangeRequest) {
                page = MenuChangeRequestScreen(
                  request: request,
                );
              } else if (request is OtherRequest) {
                page = OtherRequestScreen(
                  request: request,
                );
              }
              navigatorPush(context, page);
            },
            label: const Text('Edit'),
            icon: const Icon(Icons.edit_rounded),
          ),
        if ((widget.request.requestingUserEmail == currentUser.email &&
                widget.request.status == RequestStatus.pending) ||
            currentUser.permissions.requests.delete == true)
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
        if (currentUser.type != 'student')
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
        if (currentUser.type != 'student')
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
