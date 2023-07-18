import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/main.dart';

import '../../tools.dart';

enum RequestStatus { pending, approved, denied }

abstract class Request {
  /// [id] also denotes when was the request created
  int id = 0;

  late String requestingUserEmail;

  /// The status of the request
  RequestStatus status = RequestStatus.pending;

  /// This represents when was the request approved or denied
  int closedAt = 0;

  List<String> _approvers = [];

  /// Return the list of approvers from cache
  Future<List<String>> get approvers async {
    if (_approvers.isEmpty) return await fetchApprovers(src: Source.cache);
    return _approvers;
  }

  /// This denotes the type of request
  late String type;

  String reason = "";

  /// This function is used to store data into a map with string keys
  /// override it to store more properties in the map returned from super.encode()
  Map<String, dynamic> encode() {
    return {
      "id": id,
      "status": status.index,
      "type": type,
      "reason": reason,
      "requestingUserEmail": requestingUserEmail,
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
  }

  /// This function is when the request is status
  void onApprove();

  /// This function is called every time the request is updated
  /// Do some checks on whether it is possible to update the request or not
  /// Like for van request is that time slot available or not
  bool onPost() {
    final String? err = Validate.email(requestingUserEmail, required: true);
    if (err != null) throw err;
    return true;
  }

  /// Does what it does
  Future<void> update() async {
    if (!onPost()) return;
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
    _approvers = data['approvers'];
    if (_approvers.isEmpty) throw "No approver found for request type: $type";
    return _approvers;
  }

  /// Use this function to update this request's list of approvers
  Future<void> updateApprovers({required List<String> approvers}) async {
    final doc = firestore.collection('requests').doc(type);
    await doc.set({'approvers': approvers});
    _approvers = approvers;
  }
}
