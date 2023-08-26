import 'dart:math';

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
import 'package:hustle_stay/providers/notifications/notifications.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/request_info.dart';
import 'package:hustle_stay/widgets/requests/requests_bottom_bar.dart';

enum RequestStatus { pending, approved, denied }

// const infDateMillisec = 8640000000000000;
// final infDate = DateTime.fromMillisecondsSinceEpoch(infDateMillisec);

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

  /// This represents when was the request last modified
  int modifiedAt = 0;

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
      // locked: status != RequestStatus.pending,
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
      // "expiryDate": expiryDate.millisecondsSinceEpoch,
      "deletedAt": deletedAt == null ? null : deletedAt!.millisecondsSinceEpoch,
      "closedAt": closedAt,
      "modifiedAt": modifiedAt,
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
    modifiedAt = data['modifiedAt'] ?? modifiedAt;
    requestingUserEmail = data['requestingUserEmail'] ?? requestingUserEmail;
    // expiryDate = DateTime.fromMillisecondsSinceEpoch(data['expiryDate'] ?? 0);
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
    final now = DateTime.now();
    await update();
    await addMessage(
      chatData,
      MessageData(
        id: now.microsecondsSinceEpoch.toString(),
        txt:
            "${currentUser.name ?? currentUser.email} ${status.name} the request at \n${ddmmyyyy(now)} ${timeFrom(now)}",
        from: currentUser.email!,
        createdAt: DateTime.now(),
        indicative: true,
      ),
    );
  }

  Future<void> deny() async {
    status = RequestStatus.denied;
    final now = DateTime.now();
    await update();
    await addMessage(
      chatData,
      MessageData(
        id: now.microsecondsSinceEpoch.toString(),
        txt:
            "${currentUser.name ?? currentUser.email} ${status.name} the request at \n${ddmmyyyy(now)} ${timeFrom(now)}",
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
  Future<void> update() async {
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
      }

      final doc = firestore.collection('requests').doc(id.toString());

      modifiedAt = DateTime.now().millisecondsSinceEpoch;

      // Finally updating the doc
      transaction.set(doc, encode());
      transaction.update(firestore.doc('modifiedAt/requests'), {
        "lastModifiedAt": modifiedAt,
      });
    });
    approvers.map((e) => e).forEach((email) async {
      await sendNotification(
        toEmail: email,
        title: type,
        body: reason,
        data: {
          'path': chatData.path,
          'type': 'creation',
        },
      );
    });
  }

  /// Does what it does
  Future<void> fetch({Source? src}) async {
    final doc = firestore.collection('requests').doc(id.toString());
    final response =
        await doc.get(src == null ? null : GetOptions(source: src));
    load(response.data() ?? {});
  }

  /// Does what it says
  Future<void> delete() async {
    deletedAt = DateTime.now();
    await update();
  }

  /// Use this function to get this request's list of approvers
  Future<List<String>> fetchApprovers({Source? src}) async {
    if (type != 'Other') {
      return await fetchApproversOfRequestType(type);
    } else {
      return approvers;
    }
  }

  /// Use this function to update this request's list of approvers
  Future<void> updateApprovers({required List<String> newApprovers}) async {
    final batch = firestore.batch();
    final modifiedAt = DateTime.now().millisecondsSinceEpoch;
    if (type != 'Other') {
      final doc = firestore.collection('requests').doc(type);
      batch.set(doc, {
        'approvers': newApprovers,
        'modifiedAt': modifiedAt,
        'isType': true,
        'status': RequestStatus.pending.index,
      });
    } else {
      final doc = firestore.collection('requests').doc(id.toString());
      batch.update(doc, {
        'approvers': newApprovers,
        'modifiedAt': modifiedAt,
      });
    }
    batch.set(firestore.doc('modifiedAt/requests'), {
      "lastModifiedAt": modifiedAt,
    });
    await batch.commit();
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
            'Last Modified at':
                ddmmyyyy(DateTime.fromMillisecondsSinceEpoch(modifiedAt)),
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

ValueNotifier<String?> requestsIntialized = ValueNotifier(null);

Future<void> initializeApprovers() async {
  requestsIntialized.value = "Fetching Approvers";
  const String key = 'approversLastModifiedAt';
  int approversLastModifiedAt = -1;
  final docs = await fetchAllApprovers(
    src: Source.serverAndCache,
    lastModifiedAt: approversLastModifiedAt,
  );
  int maxModifiedAt = approversLastModifiedAt;
  for (final doc in docs) {
    maxModifiedAt = max(maxModifiedAt, doc.data()['modifiedAt']);
  }
  prefs!.setInt(key, maxModifiedAt);
  requestsIntialized.value = null;
}

Future<void> initializeRequests() async {
  await initializeApprovers();
  requestsIntialized.value = "Fetching Requests";
  const String key = 'requestsLastModifiedAt';
  int requestsLastModifiedAt = prefs!.getInt(key) ?? -1;
  // If requestsLastModifiedAt is not yet available then
  // find it from cache
  // if (requestsLastModifiedAt == -1) {
  //   try {
  //     requestsLastModifiedAt = (await firestore
  //             .collection('requests')
  //             .orderBy('modifiedAt', descending: true)
  //             .limit(1)
  //             .get(const GetOptions(source: Source.cache)))
  //         .docs[0]
  //         .data()['modifiedAt'];
  //   } catch (e) {
  //     // if data doesn't exists in cache then do nothing
  //   }
  // }
  final requests = await fetchRequests(
    src: Source.serverAndCache,
    lastModifiedAt: requestsLastModifiedAt,
  );
  int maxModifiedAt = requestsLastModifiedAt;
  for (var request in requests) {
    maxModifiedAt = max(maxModifiedAt, request.modifiedAt);
  }
  prefs!.setInt(key, maxModifiedAt);
  requestsIntialized.value = null;
}

/// Fetch approvers of specific request type (type shouldn't be Other)
Future<List<String>> fetchApproversOfRequestType(String requestType) async {
  if (requestType == 'Other') return [];
  final doc = firestore.collection('requests').doc(requestType);
  DocumentSnapshot<Map<String, dynamic>>? response;
  response = await doc.get(const GetOptions(source: Source.cache));
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

bool approversInitialized = false;

/// Fetch All Approvers
Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAllApprovers({
  int? lastModifiedAt,
  Source src = Source.cache,
}) async {
  Query<Map<String, dynamic>> query =
      firestore.collection('requests').where('isType', isEqualTo: true);
  if (lastModifiedAt != null) {
    query = query.where('modifiedAt', isGreaterThan: lastModifiedAt);
  }
  final response = await query.get(GetOptions(source: src));
  for (var doc in response.docs) {
    Request.allApprovers[doc.id] = (doc.data()['approvers'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
  }
  approversInitialized = true;
  return response.docs;
}

/// Before calling this function make sure that
/// you first initialize approvers as well
Future<List<Request>> fetchRequests({
  RequestStatus? status,
  int? limit,
  Map<String, DocumentSnapshot>? savePoint,
  int? lastModifiedAt,
  Source src = Source.cache,
}) async {
  debugPrint("Fetching requests from $src");
  assert(lastModifiedAt == null || savePoint == null || savePoint.isEmpty);

  if (approversInitialized == false) {
    await fetchAllApprovers();
  }

  final List<Request> ans = [];

  /// REQUESTS POSTED BY THIS USER
  Query<Map<String, dynamic>> query = firestore
      .collection('requests')
      .where('requestingUserEmail', isEqualTo: currentUser.email);
  query = sanitizeRequestsQuery(
    query,
    status,
    limit,
    savePoint,
    'myRequests',
    lastModifiedAt,
  );
  QuerySnapshot<Map<String, dynamic>> response =
      await query.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['myRequests'] = response.docs.last;
  }
  ans.addAll(response.docs.map((doc) => decodeToRequest(doc.data())));

  /// REQUESTS OF WHOM THE USER IS AN APPROVER
  List<String> types = [];

  /// Fetching my types
  response = await firestore
      .collection('requests')
      .where('isType', isEqualTo: true)
      .where('approvers', arrayContains: currentUser.email)
      .get(const GetOptions(source: Source.cache));
  types = response.docs.map((e) => e.id).toList();
  if (types.isEmpty) return ans;

  /// Fetching requests of [types]
  query = firestore.collection('requests').where('type', whereIn: types);
  query = sanitizeRequestsQuery(
    query,
    status,
    limit,
    savePoint,
    'approversRequests',
    lastModifiedAt,
  );
  response = await query.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['approversRequests'] = response.docs.last;
  }
  ans.addAll(response.docs.map((doc) => decodeToRequest(doc.data())));

  // FETCHING REQUESTS OF TYPE 'OTHER'
  query = firestore
      .collection('requests')
      .where('type', isEqualTo: 'Other')
      .where('approvers', arrayContains: currentUser.email);
  query = sanitizeRequestsQuery(
    query,
    status,
    limit,
    savePoint,
    'otherRequests',
    lastModifiedAt,
  );
  response = await query.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['otherRequests'] = response.docs.last;
  }
  ans.addAll(response.docs.map((doc) => decodeToRequest(doc.data())));
  return ans;
}

ValueNotifier<String?> vehicleRequestsIntialized = ValueNotifier(null);

Future<void> initializeVehicleRequests() async {
  vehicleRequestsIntialized.value = "Fetching Vehicle Requests";
  const String key = 'vehicleRequestsLastModifiedAt';
  int vehicleRequestsLastModifiedAt = prefs!.getInt(key) ?? -1;
  final requests = await fetchVehicleRequests(
    src: Source.serverAndCache,
    lastModifiedAt: vehicleRequestsLastModifiedAt,
  );
  int maxModifiedAt = vehicleRequestsLastModifiedAt;
  for (var request in requests) {
    maxModifiedAt = max(maxModifiedAt, request.modifiedAt);
  }
  prefs!.setInt(key, maxModifiedAt);
  vehicleRequestsIntialized.value = null;
}

Future<List<VehicleRequest>> fetchVehicleRequests({
  RequestStatus? status = RequestStatus.approved,
  int? limit,
  Map<String, DocumentSnapshot>? savePoint,
  int? lastModifiedAt,
  Source src = Source.cache,
}) async {
  assert(lastModifiedAt == null || savePoint == null || savePoint.isEmpty);

  final List<VehicleRequest> ans = [];

  /// VEHICLE REQUESTS
  Query<Map<String, dynamic>> query =
      firestore.collection('requests').where('type', isEqualTo: 'Vehicle');
  query = sanitizeRequestsQuery(
    query,
    status,
    limit,
    savePoint,
    'vehicleRequests',
    lastModifiedAt,
    orderBy: lastModifiedAt == null ? "dateTime" : null,
  );
  QuerySnapshot<Map<String, dynamic>> response =
      await query.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['vehicleRequests'] = response.docs.last;
  }
  ans.addAll(response.docs
      .map((doc) => decodeToRequest(doc.data()) as VehicleRequest));
  return ans;
}

Query<Map<String, dynamic>> sanitizeRequestsQuery(
    Query<Map<String, dynamic>> query,
    RequestStatus? status,
    int? limit,
    Map<String, DocumentSnapshot>? savePoint,
    String saveKey,
    int? lastModifiedAt,
    {String? orderBy}) {
  query = query.where('deletedAt', isNull: true);
  if (status != null) {
    query = query.where('status', isEqualTo: status.index);
  }
  if (lastModifiedAt != null) {
    query = query.where('modifiedAt', isGreaterThan: lastModifiedAt);
  }
  query = query.orderBy(
      orderBy ??
          (lastModifiedAt != null
              ? 'modifiedAt'
              : (status == null || status == RequestStatus.pending
                  ? 'id'
                  : 'closedAt')),
      descending: true);
  if (savePoint != null && savePoint[saveKey] != null) {
    query = query.startAfterDocument(savePoint[saveKey]!);
  }
  if (limit != null) {
    query = query.limit(limit);
  }
  return query;
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
    if (widget.request.approvers.contains(currentUser.email) &&
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
                bottomBar:
                    (!widget.request.approvers.contains(currentUser.email))
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
              // Positioned(
              //   right: 0,
              //   child: CacheBuilder(
              //       loadingWidget: AnimateIcon(
              //         height: 15,
              //         width: 15,
              //         color: Colors.blue.withOpacity(0.1),
              //         onTap: () {},
              //         iconType: IconType.continueAnimation,
              //         animateIcon: AnimateIcons.loading7,
              //       ),
              //       builder: (ctx, msg) {
              //         if (msg == null ||
              //             msg.readBy.contains(currentUser.email!)) {
              //           return Container();
              //         }
              //         return AnimateIcon(
              //           height: 15,
              //           width: 15,
              //           color: Colors.red,
              //           onTap: () {},
              //           iconType: IconType.continueAnimation,
              //           animateIcon: AnimateIcons.bell,
              //         );
              //       },
              //       provider: ({Source? src}) async {
              //         return await fetchLastMessage(
              //           "requests/${widget.request.id}",
              //           // src: src,
              //         );
              //       }),
              // ),
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
              if (widget.request.approvers.contains(currentUser.email))
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
