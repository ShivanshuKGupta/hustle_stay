import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/requests/hostel/add_leave_request.dart';
import 'package:hustle_stay/models/requests/hostel/cancel_leave_request.dart';
import 'package:hustle_stay/models/requests/hostel/change_room_request.dart';
import 'package:hustle_stay/models/requests/hostel/swap_room_request.dart';
import 'package:hustle_stay/models/requests/hostel/update_leave_request.dart';
import 'package:hustle_stay/models/requests/mess/menu_change_request.dart';
import 'package:hustle_stay/models/requests/other/other_request.dart';
import 'package:hustle_stay/models/requests/vehicle/vehicle_request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/request_info.dart';
import 'package:hustle_stay/widgets/requests/requests_bottom_bar.dart';

enum RequestStatus { pending, approved, denied }

const infDateMillisec = 8640000000000000;
final infDate = DateTime.fromMillisecondsSinceEpoch(infDateMillisec);

abstract class Request {
  /// Constructor
  Request({
    required this.requestingUserEmail,
    required this.type,
    required this.uiElement,
  });

  /// [id] also denotes when was the request created,
  /// its id in firestore and
  int id = 0;

  /// The email id of the user who created this request
  late String requestingUserEmail;

  /// The status of the request
  RequestStatus status = RequestStatus.pending;

  /// This represents when was the request approved or denied
  int closedAt = 0;

  /// The date after which the request will disappear from the UI
  DateTime expiryDate = infDate; // infinite time

  /// Deleted At
  DateTime? deletedAt;

  List<String> get approvers {
    if (type != 'Other') {
      return allApprovers[type]!;
    } else {
      return allApprovers[id.toString()] ?? [];
    }
  }

  set approvers(List<String> value) {
    if (type != 'Other') {
      allApprovers[type] = value;
    } else {
      allApprovers[id.toString()] = value;
    }
  }

  /// Map<RequestTypeName, List<approvers>>
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
      title: type.replaceAll('_', ' '),
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
      "deletedAt": deletedAt == null ? null : deletedAt!.millisecondsSinceEpoch,
      "closedAt": closedAt,
      if (type == 'Other') 'approvers': approvers,
    };
  }

  /// This function is used to load data into the object
  /// override it to include more properties in it
  void load(Map<String, dynamic> data) {
    id = data['id'] ?? id;
    status = RequestStatus.values[data['status'] ?? status.index];
    type = data['type'] ?? type;
    reason = data['reason'] ?? reason;
    closedAt = data['closedAt'] ?? closedAt;
    requestingUserEmail = data['requestingUserEmail'] ?? requestingUserEmail;
    expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate'] ?? 0);
    deletedAt = data['deletedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(data['deletedAt']);
    if (type == 'Other') {
      approvers = (data['approvers'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }
  }

  Future<void> approve() async {
    status = RequestStatus.approved;
    await update();
    await addMessage(
      chatData,
      MessageData(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        txt:
            "${currentUser.name ?? currentUser.email} ${status.name} the request at \n${ddmmyyyy(DateTime.now())} ${timeFrom(DateTime.now())}",
        from: currentUser.email!,
        createdAt: DateTime.now(),
        indicative: true,
      ),
    );
  }

  Future<void> deny() async {
    status = RequestStatus.denied;
    await update();
    await addMessage(
      chatData,
      MessageData(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        txt:
            "${currentUser.name ?? currentUser.email} ${status.name} the request at \n${ddmmyyyy(DateTime.now())} ${timeFrom(DateTime.now())}",
        from: currentUser.email!,
        createdAt: DateTime.now(),
        indicative: true,
      ),
    );
  }

  /// This function is when the request is approved
  /// This contains a transaction, so as to make the updation and
  /// onApprove function run atomically.
  Future<void> onApprove(Transaction? transaction);

  /// This function is called every time the request is updated
  /// Do some checks on whether it is possible to update the request or not
  /// Like for vehicle request is that time slot available or not
  bool beforeUpdate() {
    final String? err = Validate.email(requestingUserEmail, required: true);
    if (err != null) throw err;

    // if the request doesn't have an id
    if (id == 0) {
      id = DateTime.now().millisecondsSinceEpoch;
    }

    return true;
  }

  /// Does what it does
  Future<void> update({DateTime? chosenExpiryDate}) async {
    await firestore.runTransaction((transaction) async {
      // Some checks
      if (!beforeUpdate()) return;

      // if the request is being closed down or is already closed
      if (status != RequestStatus.pending) {
        // If closed at is not set yet (first time being closed)
        if (closedAt == 0) {
          closedAt = DateTime.now().millisecondsSinceEpoch;
          if (status == RequestStatus.approved) {
            await onApprove(transaction);
          }
        }

        // if expiry date is not set yet
        if (expiryDate == infDate) {
          final closedDateTime = DateTime.fromMillisecondsSinceEpoch(closedAt);
          // setting the expiry to 7 days after closedAt
          expiryDate = DateTime(closedDateTime.year, closedDateTime.month,
              closedDateTime.day + 7);
        }
      }

      // If a custom expiry date is specified
      if (chosenExpiryDate != null) {
        expiryDate = chosenExpiryDate;
      }

      final doc = firestore.collection('requests').doc(id.toString());

      // Finally updating the doc
      transaction.set(doc, encode());
    });
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
    if (type != 'Other') {
      return await fetchApproversOfRequestType(type, src: src);
    } else {
      return approvers;
    }
  }

  /// Use this function to update this request's list of approvers
  Future<void> updateApprovers({required List<String> newApprovers}) async {
    if (type != 'Other') {
      final doc = firestore.collection('requests').doc(type);
      await doc.set({'approvers': newApprovers});
    } else {
      final doc = firestore.collection('requests').doc(id.toString());
      await doc.update({'approvers': newApprovers});
    }
    approvers = newApprovers;
  }

  Map<String, dynamic> uiElement;

  /// This function returns a custom widget for this type of request
  Widget widget(BuildContext context);

  /// This is the function returns a custom widget for this type of request
  @protected
  Widget listWidget(
    Widget? detailWidget,
    Map<String, String> otherDetails,
  ) {
    return RequestItem(
      request: this,
      otherDetails: otherDetails,
      detailWidget: detailWidget,
    );
  }

  void showInfo(BuildContext context, Map<String, String> otherDetails) async {
    DateTime closedDateTime = DateTime.fromMillisecondsSinceEpoch(closedAt);
    Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        builder: (BuildContext context) => RequestInfo(
          request: this,
          details: {
            'From': requestingUserEmail,
            'Requested at': ddmmyyyy(DateTime.fromMillisecondsSinceEpoch(id)),
            'Status': status.name,
            if (status != RequestStatus.pending)
              'Closed at':
                  "${ddmmyyyy(closedDateTime)} ${timeFrom(closedDateTime)}",
            'Approvers': approvers.toString(),
            'Reason': reason,
            if (type == 'Other') 'Approvers': approvers.toString(),
            ...otherDetails,
          },
        ),
      ),
    );
  }
}

/// Fetch approvers of specific request type (type shouldn't be Other)
Future<List<String>> fetchApproversOfRequestType(String requestType,
    {Source? src}) async {
  if (requestType == 'Other') return [];
  final doc = firestore.collection('requests').doc(requestType);
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    response = await doc.get(src == null ? null : GetOptions(source: src));
  } catch (e) {
    if (src == Source.cache) return fetchApproversOfRequestType(requestType);
    rethrow;
  }
  if (response.data() == null && src == Source.cache) {
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

Request decodeToRequest(Map<String, dynamic> data) {
  final type = data['type'];
  if (type == 'Vehicle') {
    return VehicleRequest(
      requestingUserEmail: data['requestingUserEmail'],
      title: data['title'],
    )..load(data);
  } else if (type == 'Menu_Change') {
    return MenuChangeRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  } else if (type == 'Other') {
    return OtherRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  } else if (type == 'Change_Room') {
    return ChangeRoomRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  } else if (type == 'Swap_Room') {
    return SwapRoomRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  } else if (type == 'Add_Leave') {
    return AddLeaveRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  } else if (type == 'Update_Leave') {
    return UpdateLeaveRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  } else if (type == 'Cancel_Leave') {
    return CancelLeaveRequest(requestingUserEmail: data['requestingUserEmail'])
      ..load(data);
  }
  throw "No such type exists: '$type'";
}

/// It returns requests and fetches required approvers as well
Future<List<Request>> getStudentRequests({Source? src}) async {
  final collection = firestore.collection('requests');
  final response = await collection
      .where('requestingUserEmail', isEqualTo: currentUser.email)
      .where(
        'expiryDate',
        isGreaterThan: DateTime.now().millisecondsSinceEpoch,
      )
      .get(src == null ? null : GetOptions(source: src));
  final docs = response.docs;
  Set<String> requestTypes = {};
  List<Request> requests = docs.map((doc) {
    final data = doc.data();
    final type = data['type'];
    requestTypes.add(type);
    return decodeToRequest(data);
  }).toList();
  for (var e in requestTypes) {
    fetchApproversOfRequestType(e, src: src);
  }
  return requests;
}

/// It returns requests and fetches required approvers as well
Future<List<Request>> getApproverRequests({Source? src}) async {
  final collection = firestore.collection('requests');
  var response = await collection
      .where('approvers', arrayContains: currentUser.email)
      .where('status', isEqualTo: RequestStatus.pending.index)
      .get(src == null ? null : GetOptions(source: src));
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = response.docs;
  final List<Request> requests = [];
  final List<String> types = [];
  for (final doc in docs) {
    if (int.tryParse(doc.id) == null) {
      types.add(doc.id);
    } else {
      requests.add(decodeToRequest(doc.data()));
    }
  }
  if (types.isNotEmpty) {
    response = await collection
        .where('type', whereIn: types)
        .where('status', isEqualTo: RequestStatus.pending.index)
        .get(src == null ? null : GetOptions(source: src));
    docs = response.docs;
    requests.addAll(docs.map((doc) {
      final data = doc.data();
      return decodeToRequest(data);
    }));
  }
  return requests;
}

class RequestItem extends StatefulWidget {
  final Request request;
  final Widget? detailWidget;
  final Map<String, String> otherDetails;
  const RequestItem(
      {super.key,
      required this.request,
      this.detailWidget,
      required this.otherDetails});

  @override
  State<RequestItem> createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {
  @override
  Widget build(BuildContext context) {
    Widget trailing = widget.request.status == RequestStatus.pending
        ? AnimateIcon(
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              showMsg(context, 'This request is yet to be approved.');
            },
            iconType: IconType.continueAnimation,
            animateIcon: AnimateIcons.hourglass,
          )
        : IconButton(
            onPressed: () {
              showMsg(
                  context, 'This request is ${widget.request.status.name}.');
            },
            icon: Icon(
              widget.request.status == RequestStatus.approved
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: widget.request.status == RequestStatus.approved
                  ? Colors.greenAccent
                  : Colors.redAccent,
            ),
          );
    if (currentUser.type != 'student' &&
        widget.request.status == RequestStatus.pending) {
      // TODO: Remove shortcircuiting
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              final response = await askUser(
                context,
                'Do you want to approve this ${widget.request.type} request?',
                yes: true,
                no: true,
              );
              if (response == 'yes') {
                widget.request.approve();
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
                'Do you want to deny this ${widget.request.type} request?',
                yes: true,
                no: true,
              );
              if (response == 'yes') {
                widget.request.deny();
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
        color: widget.request.uiElement['color'].withOpacity(0.2),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          onTap: () async {
            await navigatorPush(
              context,
              ChatScreen(
                bottomBar: (currentUser.type == 'student')
                    ? null
                    : RequestBottomBar(request: widget.request),
                showInfo: () =>
                    widget.request.showInfo(context, widget.otherDetails),
                chat: widget.request.chatData,
              ),
            );
            setState(() {});
          },
          onLongPress: () {
            widget.request.showInfo(context, widget.otherDetails);
          },
          leading: Stack(
            children: [
              Icon(widget.request.uiElement['icon'], size: 50),
              Positioned(
                right: 0,
                child: CacheBuilder(
                    loadingWidget: AnimateIcon(
                      height: 15,
                      width: 15,
                      color: Colors.blue.withOpacity(0.1),
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.loading7,
                    ),
                    builder: (ctx, msg) {
                      if (msg == null ||
                          msg.readBy.contains(currentUser.email!)) {
                        return Container();
                      }
                      return AnimateIcon(
                        height: 15,
                        width: 15,
                        color: Colors.red,
                        onTap: () {},
                        iconType: IconType.continueAnimation,
                        animateIcon: AnimateIcons.bell,
                      );
                    },
                    provider: ({Source? src}) async {
                      return await fetchLastMessage(
                        "requests/${widget.request.id}",
                        // src: src,
                      );
                    }),
              ),
            ],
          ),
          title: Text('${widget.request.type.replaceAll('_', ' ')} Request',
              overflow: TextOverflow.fade),
          trailing: trailing,
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.detailWidget != null) widget.detailWidget!,
              if (currentUser.type != 'student')
                UserBuilder(
                  email: widget.request.requestingUserEmail,
                  builder: (ctx, userData) => Text(
                    userData.name ?? userData.email!,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: widget.request.uiElement['color'],
                        ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
