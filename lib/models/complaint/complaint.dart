import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/state_switch.dart';
import 'package:hustle_stay/tools.dart';

enum Scope {
  public,
  private,
}

class ComplaintData {
  String? description;
  late String from;

  /// createdAt dateTime object converted into a string or integer
  late int id;

  /// resolvedAt dateTime object converted into a string or integer
  int? resolvedAt;
  late Scope scope;
  late List<String> to;
  String? category;

  /// title is synonymous to category
  String get title {
    return category ?? 'Other';
  }

  /// DateTime of deletion
  DateTime? deletedAt;

  /// DateTime of deletion
  int modifiedAt = 0;

  ComplaintData({
    this.description = "",
    required this.from,
    required this.id,
    this.scope = Scope.public,
    required this.to,
    this.resolvedAt,
    this.deletedAt,
    this.category,
  });

  Map<String, dynamic> encode() {
    return {
      "description": description,
      "from": from,
      "scope": scope.name,
      "to": to,
      "resolvedAt": resolvedAt,
      "resolved": resolvedAt != null,
      "modifiedAt": modifiedAt,
      "deletedAt": deletedAt == null ? null : deletedAt!.millisecondsSinceEpoch,
      "category": category,
      "createdAt": id,
    };
  }

// bool complaintsInitialized = false;

//   Future<void> initializeUsers() async {
//     const String key = 'complaintsLastModifiedAt';
//     final int usersLastModifiedAt = prefs!.getInt(key) ?? -1;
//     final response = await firestore
//         .collection('complaints')
//         .where(
//           'modifiedAt',
//           isGreaterThan: usersLastModifiedAt,
//         )
//         .get();
//     int maxModifiedAt = usersLastModifiedAt;
//     for (var doc in response.docs) {
//       maxModifiedAt = max(maxModifiedAt,
//           (UserData(email: doc.id)..load(doc.data())).modifiedAt);
//     }
//     prefs!.setInt(key, maxModifiedAt);
//     complaintsInitialized = true;
//   }

  String operator -(ComplaintData newComplaint) {
    String ans = "";
    bool addAnd = false;
    if (newComplaint.description != description) {
      ans +=
          '\nDescription from \'$description\' to \'${newComplaint.description}\'';
      addAnd = true;
    }
    if (!equalList(newComplaint.to, to)) {
      ans += (addAnd ? " and " : '');
      ans += '\nComplainees from $to to \'${newComplaint.to}\'';
      addAnd = true;
    }
    if (newComplaint.scope != scope) {
      ans += (addAnd ? " and " : '');
      ans += '\nScope from ${scope.name} to \'${newComplaint.scope.name}\'';
      addAnd = true;
    }
    if (newComplaint.category != category) {
      ans += (addAnd ? " and " : '');
      ans += '\nCategory from $category to \'${newComplaint.category}\'';
      addAnd = true;
    }
    return ans;
  }

  /// Converts a Map<String, dynamic> to a Complaint Object
  ComplaintData.load(this.id, Map<String, dynamic> complaintData) {
    description = complaintData["description"];
    from = complaintData["from"];
    scope = Scope.values
        .firstWhere((element) => element.name == complaintData["scope"]);
    resolvedAt = complaintData["resolvedAt"];
    modifiedAt = complaintData["modifiedAt"] ?? 0;
    // if (complaintData["deletedAt"] != null &&
    //     complaintData["deletedAt"] is Timestamp) {
    //   deletedAt = DateTime.fromMillisecondsSinceEpoch(
    //       (complaintData["deletedAt"] as Timestamp).millisecondsSinceEpoch);
    // } else {
    deletedAt = complaintData["deletedAt"] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(complaintData["deletedAt"]);
    // }
    category = complaintData["category"];
    to = (complaintData["to"] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    // Below code was used to correct the data in the db and is no longer needed
    // if (complaintData['deletedAt'] == null) updateComplaint(this);
    // if (complaintData['createdAt'] == null ||
    //     complaintData['createdAt'].runtimeType != int) {
    //   updateComplaint(this);
    // }
    // if (complaintData["resolvedAt"] != null &&
    //     complaintData["resolvedAt"].runtimeType != int) {
    //   updateComplaint(this);
    // }

    //   updateComplaint(this);
    // }
    // --------------
  }
}

ValueNotifier<String?> complaintsInitialized = ValueNotifier(null);

Future<void> initializeComplaints() async {
  complaintsInitialized.value = "Fetching Complaints";
  const String key = 'complaintsLastModifiedAt';
  int complaintsLastModifiedAt = prefs!.getInt(key) ?? -1;
  // If complaintsLastModifiedAt is not yet available then
  // find it from cache
  if (complaintsLastModifiedAt == -1) {
    try {
      complaintsLastModifiedAt = (await firestore
              .collection('complaints')
              .orderBy('modifiedAt', descending: true)
              .limit(1)
              .get(const GetOptions(source: Source.cache)))
          .docs[0]
          .data()['modifiedAt'];
    } catch (e) {
      // if data doesn't exists in cache then do nothing
    }
  }
  final complaints = await fetchComplaints(
    src: Source.serverAndCache,
    resolved: false,
    lastModifiedAt: complaintsLastModifiedAt,
  );
  complaintsInitialized.value = "Fetching Resolved Complaints";
  complaints.addAll(
    await fetchComplaints(
      src: Source.serverAndCache,
      resolved: true,
      lastModifiedAt: complaintsLastModifiedAt,
    ),
  );
  int maxModifiedAt = complaintsLastModifiedAt;
  for (var complaint in complaints) {
    maxModifiedAt = max(maxModifiedAt, complaint.modifiedAt);
  }
  prefs!.setInt(key, maxModifiedAt);
  complaintsInitialized.value = null;
}

bool equalList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = a.length; i-- > 0;) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// updates an exisiting complaint or will create if complaint does not exists
Future<ComplaintData> updateComplaint(ComplaintData complaint) async {
  if (complaint.id == 0) complaint.id = DateTime.now().millisecondsSinceEpoch;
  if (complaint.to.isEmpty) {
    Category category = await fetchCategory(complaint.category ?? 'Other');
    while (category.parent != null) {
      category = await fetchCategory(category.parent!);
    }
    complaint.to = category.defaultReceipient;
  }
  complaint.modifiedAt = DateTime.now().millisecondsSinceEpoch;
  await firestore.doc('complaints/${complaint.id}').set(complaint.encode());
  return complaint;
}

/// updates an exisiting complaint or will create if complaint does not exists
Future<void> deleteComplaint(ComplaintData complaint) async {
  final bool isDeleted = complaint.deletedAt != null;
  final now = DateTime.now();
  complaint.modifiedAt = DateTime.now().millisecondsSinceEpoch;
  await firestore
      .doc('complaints/${complaint.id}')
      .update({'deletedAt': isDeleted ? null : now.millisecondsSinceEpoch});
  await addMessage(
    ChatData(
      path: "complaints/${complaint.id}",
      owner: complaint.from,
      receivers: complaint.to,
      title: complaint.title,
      description: complaint.description,
    ),
    MessageData(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      txt:
          "${currentUser.name ?? currentUser.email} ${isDeleted ? 'restored' : 'deleted'} the complaint at ${ddmmyyyy(now)} ${timeFrom(now)}",
      from: currentUser.email!,
      createdAt: DateTime.now(),
      indicative: true,
    ),
  );
}

/// fetches a complaint of given ID
Future<ComplaintData> fetchComplaint(int id) async {
  final response = await firestore
      .doc('complaints/$id')
      .get(const GetOptions(source: Source.cache));
  if (!response.exists) throw "Complaint Doesn't exists";
  final data = response.data();
  if (data == null) throw "Data not found";
  return ComplaintData.load(id, data);
}

// /// fetches all complaints
// Future<List<ComplaintData>> fetchComplaints({
//   Source? src,
// }) async {
//   // Fetching all public complaints
//   final publicComplaints = await firestore
//       .collection('complaints')
//       .where('scope', isEqualTo: 'public')
//       .where('deletedAt', isNull: true)
//       .where('resolvedAt', isNull: true)
//       .get(src != null ? GetOptions(source: src) : null);
//   List<ComplaintData> ans = publicComplaints.docs
//       .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
//       .toList();
//   // Fetching Private Complaints made by the user itself
//   final myComplaints = await firestore
//       .collection('complaints')
//       .where('from', isEqualTo: currentUser.email)
//       .where('scope', isEqualTo: 'private')
//       .where('deletedAt', isNull: true)
//       .where('resolvedAt', isNull: true)
//       .get(src != null ? GetOptions(source: src) : null);
//   ans += myComplaints.docs
//       .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
//       .toList();
//   // Fetching all complaints in which the user is included
//   final includedComplaints = await firestore
//       .collection('complaints')
//       .where('to', arrayContains: currentUser.email)
//       .where('scope', isEqualTo: 'private')
//       .where('deletedAt', isNull: true)
//       .where('resolvedAt', isNull: true)
//       .get(src != null ? GetOptions(source: src) : null);
//   ans += includedComplaints.docs
//       .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
//       .toList();
//   ans.sort((a, b) => (a.id < b.id) ? 1 : 0);
//   return ans;
// }

/// A widget used to display a child widget using a list of Complaints
class ComplaintsBuilder extends ConsumerWidget {
  final Widget Function(BuildContext ctx, List<ComplaintData> complaints)
      builder;
  final Future<List<ComplaintData>> Function({Source? src})? complaintsProvider;
  final Widget? loadingWidget;
  const ComplaintsBuilder({
    super.key,
    this.complaintsProvider,
    required this.builder,
    this.loadingWidget,
  });

  /// Use this to store data
  static List<ComplaintData> complaints = const [];

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(complaintBuilderSwitch);
    return FutureBuilder(
      future: complaintsProvider != null
          ? complaintsProvider!()
          : fetchComplaints(),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error.toString();
        }
        if (!snapshot.hasData) {
          return complaints.isEmpty && loadingWidget != null
              ? loadingWidget!
              : builder(context, complaints);
        }
        // Returning this widget when data arrives from server
        ComplaintsBuilder.complaints = snapshot.data!;
        return builder(ctx, complaints);
      },
    );
  }
}

final complaintBuilderSwitch = createSwitch();

/// set lastModified to fetch only complaints after a certain modifiedAt
Future<List<ComplaintData>> fetchComplaints({
  bool resolved = false,
  int? limit,
  Map<String, DocumentSnapshot>? savePoint,
  int? lastModifiedAt,
  Source src = Source.cache,
}) async {
  assert(lastModifiedAt == null || savePoint == null || savePoint.isEmpty);

  // FETCHING PUBLIC COMPLAINTS
  Query<Map<String, dynamic>> publicComplaints = firestore
      .collection('complaints')
      .where('scope', isEqualTo: 'public')
      .where('deletedAt', isNull: true)
      .where('resolved', isEqualTo: resolved);
  if (lastModifiedAt != null) {
    publicComplaints =
        publicComplaints.where('modifiedAt', isGreaterThan: lastModifiedAt);
  }
  publicComplaints = publicComplaints.orderBy(
      lastModifiedAt != null
          ? 'modifiedAt'
          : (resolved ? 'resolvedAt' : 'createdAt'),
      descending: true);
  if (savePoint != null && savePoint['publicComplaints'] != null) {
    publicComplaints =
        publicComplaints.startAfterDocument(savePoint['publicComplaints']!);
  }
  if (limit != null) {
    publicComplaints = publicComplaints.limit(limit);
  }
  QuerySnapshot<Map<String, dynamic>> response =
      await publicComplaints.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['publicComplaints'] = response.docs.last;
  }
  List<ComplaintData> ans = response.docs
      .map((doc) => ComplaintData.load(int.parse(doc.id), doc.data()))
      .toList();

  // FETCHING PRIVATE COMPLAINTS
  Query<Map<String, dynamic>> privateComplaints = firestore
      .collection('complaints')
      .where('scope', isEqualTo: 'private')
      .where('from', isEqualTo: currentUser.email)
      .where('deletedAt', isNull: true)
      .where('resolved', isEqualTo: resolved);
  if (lastModifiedAt != null) {
    privateComplaints =
        privateComplaints.where('modifiedAt', isGreaterThan: lastModifiedAt);
  }
  privateComplaints = privateComplaints.orderBy(
      lastModifiedAt != null
          ? 'modifiedAt'
          : (resolved ? 'resolvedAt' : 'createdAt'),
      descending: true);
  if (savePoint != null && savePoint['privateComplaints'] != null) {
    privateComplaints =
        privateComplaints.startAfterDocument(savePoint['privateComplaints']!);
  }
  if (limit != null) {
    privateComplaints = privateComplaints.limit(limit);
  }
  response = await privateComplaints.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['privateComplaints'] = response.docs.last;
  }
  ans += response.docs
      .map((doc) => ComplaintData.load(int.parse(doc.id), doc.data()))
      .toList();

  // FETCHING COMPLAINTS IN WHICH USER IS INCLUDED
  Query<Map<String, dynamic>> includedComplaints = firestore
      .collection('complaints')
      .where('scope', isEqualTo: 'private')
      .where('to', arrayContains: currentUser.email)
      .where('deletedAt', isNull: true)
      .where('resolved', isEqualTo: resolved);
  if (lastModifiedAt != null) {
    includedComplaints =
        includedComplaints.where('modifiedAt', isGreaterThan: lastModifiedAt);
  }
  includedComplaints = includedComplaints.orderBy(
      lastModifiedAt != null
          ? 'modifiedAt'
          : (resolved ? 'resolvedAt' : 'createdAt'),
      descending: true);
  if (savePoint != null && savePoint['includedComplaints'] != null) {
    includedComplaints =
        includedComplaints.startAfterDocument(savePoint['includedComplaints']!);
  }
  if (limit != null) {
    includedComplaints = includedComplaints.limit(limit);
  }
  response = await includedComplaints.get(GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['includedComplaints'] = response.docs.last;
  }
  ans += response.docs
      .map((doc) => ComplaintData.load(int.parse(doc.id), doc.data()))
      .toList();

  ans.sort((a, b) =>
      (resolved ? (a.resolvedAt! < b.resolvedAt!) : (a.id < b.id)) ? 1 : 0);

  return ans;
}
