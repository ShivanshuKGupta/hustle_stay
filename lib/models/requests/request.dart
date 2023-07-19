import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/screens/requests/attendance/attendance_request_screen.dart';
import 'package:hustle_stay/screens/requests/mess/mess_request_screen.dart';
import 'package:hustle_stay/screens/requests/other/other_request_screen.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_requests_screen.dart';

import '../../tools.dart';

enum RequestStatus { pending, approved, denied }

abstract class Request {
  /// [id] also denotes when was the request created,
  /// its id in firestore and
  int id = 0;

  late String requestingUserEmail;

  /// The status of the request
  RequestStatus status = RequestStatus.pending;

  /// This represents when was the request approved or denied
  int closedAt = 0;

  /// The date after which the request will disappear from the UI
  DateTime expiryDate =
      DateTime.fromMillisecondsSinceEpoch(8640000000000000); // infinite time

  List<String> get approvers {
    return allApprovers[type]!;
  }

  set approvers(value) {
    allApprovers[type] = value;
  }

  static Map<String, List<String>> allApprovers = {};

  /// This denotes the type of request
  late String type;

  /// The reason for posting the request
  String reason = "";

  /// To get the chat associated with it
  ChatData get chatData {
    return ChatData(
      owner: requestingUserEmail,
      receivers: approvers,
      title: type,
      locked: status != RequestStatus.pending,
      path: 'requests/$id',
    );
  }

  /// This function is used to store data into a map with string keys
  /// override it to store more properties in the map returned from super.encode()
  Map<String, dynamic> encode() {
    return {
      "id": id,
      "status": status.index,
      "type": type,
      "reason": reason,
      "requestingUserEmail": requestingUserEmail,
      "expiryDate": expiryDate.millisecondsSinceEpoch,
    };
  }

  /// This function is used to load data into the object
  /// override it to include more properties in it
  void load(Map<String, dynamic> data) {
    id = data['id'] ?? id;
    status = RequestStatus.values[data['status'] ?? status.index];
    type = data['type'] ?? type;
    reason = data['reason'] ?? reason;
    requestingUserEmail = data['requestingUserEmail'] ?? requestingUserEmail;
    expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate'] ?? 0);
  }

  Future<void> approve() async {
    status = RequestStatus.approved;
    await update();
  }

  Future<void> deny() async {
    status = RequestStatus.denied;
    await update();
  }

  /// This function is when the request is status
  void onApprove();

  /// This function is called every time the request is updated
  /// Do some checks on whether it is possible to update the request or not
  /// Like for vehicle request is that time slot available or not
  bool beforeUpdate() {
    final String? err = Validate.email(requestingUserEmail, required: true);
    if (err != null) throw err;

    // if the request is being closed down and the expiry is not set yet
    if (status != RequestStatus.pending &&
        expiryDate == DateTime.fromMillisecondsSinceEpoch(0)) {
      final closedDateTime = DateTime.fromMillisecondsSinceEpoch(closedAt);
      // then set the expiry to 7 days after closedAt
      expiryDate = DateTime(
          closedDateTime.year, closedDateTime.month, closedDateTime.day + 7);
    }

    // if the request doesn't have an id
    if (id == 0) {
      id = DateTime.now().millisecondsSinceEpoch;
    }
    return true;
  }

  /// Does what it does
  Future<void> update() async {
    if (!beforeUpdate()) return;
    final doc = firestore.collection('requests').doc(id.toString());
    await doc.set(encode());
  }

  /// Does what it does
  Future<void> fetch({Source? src}) async {
    final doc = firestore.collection('requests').doc(id.toString());
    final response =
        await doc.get(src == null ? null : GetOptions(source: src));
    load(response.data() ?? {});
  }

  /// Does what it does
  Future<void> delete() async {
    final doc = firestore.collection('requests').doc(id.toString());
    await doc.delete();
  }

  /// Use this function to get this request's list of approvers
  Future<List<String>> fetchApprovers({Source? src}) async {
    final doc = firestore.collection('requests').doc(type);
    final response =
        await doc.get(src == null ? null : GetOptions(source: src));
    final data = response.data()!;
    approvers =
        (data['approvers'] as List<dynamic>).map((e) => e.toString()).toList();
    if (approvers.isEmpty) throw "No approver found for request type: $type";
    return approvers;
  }

  /// Use this function to update this request's list of approvers
  Future<void> updateApprovers({required List<String> newApprovers}) async {
    final doc = firestore.collection('requests').doc(type);
    await doc.set({'approvers': newApprovers});
    approvers = newApprovers;
  }

  static const Map<String, Map<String, dynamic>> uiElements = {
    'Attendance': {
      'color': Colors.red,
      'icon': Icons.calendar_month_rounded,
      'route': AttendanceRequestScreen.routeName,
      'Change Room': {
        'color': Colors.blueAccent,
        'icon': Icons.transfer_within_a_station_rounded,
      },
      'Swap Room': {
        'color': Colors.pinkAccent,
        'icon': Icons.transfer_within_a_station_rounded,
      },
      'Leave Hostel': {
        'color': Colors.indigoAccent,
        'icon': Icons.exit_to_app_rounded,
      },
      'Return to Hostel': {
        'color': Colors.lightGreenAccent,
        'icon': Icons.keyboard_return_rounded,
      },
    },
    'Vehicle': {
      'color': Colors.deepPurpleAccent,
      'icon': Icons.airport_shuttle_rounded,
      'route': VehicleRequestScreen.routeName,
      'children': {
        'Night Travel': {
          'color': Colors.blue,
          'icon': Icons.nightlight_round,
          'reasonOptions': [
            'Train Arrival',
            'Train Departure',
          ],
        },
        'Hospital Visit': {
          'color': Colors.tealAccent,
          'icon': Icons.local_hospital_rounded,
          'reasonOptions': [
            'Fever',
            'Food Poisoning',
          ],
        },
        'Other Reason': {
          'color': Colors.lightGreenAccent,
          'icon': Icons.more_horiz_rounded,
          'reasonOptions': <String>[],
        },
      }
    },
    'Mess': {
      'color': Colors.lightBlueAccent,
      'icon': Icons.restaurant_menu_rounded,
      'route': MessRequestScreen.routeName,
      'Breakfast': {
        'color': Colors.pinkAccent,
        'icon': Icons.local_cafe,
      },
      'Lunch': {
        'color': Colors.deepPurpleAccent,
        'icon': Icons.restaurant,
      },
      'Snacks': {
        'color': Colors.cyanAccent,
        'icon': Icons.fastfood,
      },
      'Dinner': {
        'color': Colors.lightGreenAccent,
        'icon': Icons.local_dining,
      },
    },
    'Other': {
      'color': Colors.amber,
      'icon': Icons.more_horiz_rounded,
      'route': OtherRequestScreen.routeName,
    },
  };

  /// This function returns a custom widget for this type of request
  Widget widget(BuildContext context);

  /// This is the function returns a custom widget for this type of request
  @protected
  Widget listWidget(BuildContext context, Widget? detailWidget,
      Map<String, dynamic> uiElement) {
    Widget trailing = status == RequestStatus.pending
        ? AnimateIcon(
            onTap: () {
              showMsg(context, 'This request is yet to be approved.');
            },
            iconType: IconType.continueAnimation,
            animateIcon: AnimateIcons.hourglass,
          )
        : IconButton(
            onPressed: () {
              showMsg(context, 'This request is ${status.name}.');
            },
            icon: Icon(
              status == RequestStatus.approved
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: status == RequestStatus.approved
                  ? Colors.greenAccent
                  : Colors.redAccent,
            ),
          );
    if (currentUser.readonly.type != 'student' &&
        status == RequestStatus.pending &&
        false) {
      // TODO: Remove shortcircuiting
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              final response = await askUser(
                context,
                'Do you want to approve this $type request?',
                yes: true,
                no: true,
              );
              if (response == 'yes') {
                approve();
              }
            },
            icon: const Icon(
              Icons.check_rounded,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () async {
              final response = await askUser(
                context,
                'Do you want to deny this $type request?',
                yes: true,
                no: true,
              );
              if (response == 'yes') {
                deny();
              }
            },
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    return GlassWidget(
      radius: 30,
      child: Container(
        color: uiElement['color'].withOpacity(0.2),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          onTap: () {
            navigatorPush(
              context,
              ChatScreen(
                chat: chatData,
              ),
            );
          },
          onLongPress: () {
            showInfo(context, uiElement);
          },
          leading: Icon(uiElement['icon'], size: 50),
          title: Text('$type Request'),
          trailing: trailing,
          subtitle: detailWidget,
        ),
      ),
    );
  }

  void showInfo(BuildContext context, Map<String, dynamic> uiElement) async {
    final title = reason.split(':')[0];
    String subtitle = reason.substring(title.length + 2).trim();
    final theme = Theme.of(context);
    final response = await Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          scrollable: true,
          actionsPadding: const EdgeInsets.only(bottom: 15, top: 10),
          contentPadding: const EdgeInsets.only(top: 15, left: 20, right: 20),
          content: Column(
            children: [
              Icon(uiElement['icon']),
              Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "From:",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        // color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    requestingUserEmail,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Requested At:",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        // color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    ddmmyyyy(DateTime.fromMillisecondsSinceEpoch(id)),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final response = await askUser(
                    context, 'Do you really want to withdraw this request?',
                    yes: true, no: true);
                if (response == 'yes') {
                  try {
                    await delete();
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
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Withdraw'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}

/// Fetch approvers of specific request type
Future<List<String>> fetchApprovers(String requestType, {Source? src}) async {
  final doc = firestore.collection('requests').doc(requestType);
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    response = await doc.get(src == null ? null : GetOptions(source: src));
  } catch (e) {
    if (src == Source.cache) response = await doc.get();
  }
  if (response!.data() == null && src == Source.cache) {
    response = await doc.get();
  }
  final data = response.data()!;
  Request.allApprovers[requestType] =
      (data['approvers'] as List<dynamic>).map((e) => e.toString()).toList();
  if (Request.allApprovers[requestType] == null) {
    throw "No approver found for request type: $requestType";
  }
  return Request.allApprovers[requestType]!;
}
