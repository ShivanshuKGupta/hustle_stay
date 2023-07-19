import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';

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

  /// This function returns a custom widget for this type of request
  Widget widget(BuildContext context);

  /// This function is when the request is status
  void onApprove();

  /// This function is called every time the request is updated
  /// Do some checks on whether it is possible to update the request or not
  /// Like for van request is that time slot available or not
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
}

Future<List<String>> fetchApprovers(String requestType, {Source? src}) async {
  final doc = firestore.collection('requests').doc(requestType);
  var response = await doc.get(src == null ? null : GetOptions(source: src));
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
