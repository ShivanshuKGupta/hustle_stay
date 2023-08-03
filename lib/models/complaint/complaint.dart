import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/requests/request.dart';
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
  String get title {
    return category ?? 'Other';
  }

  /// DateTime of deletion
  DateTime? deletedAt;

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
      "resolved": resolvedAt != null,
      "resolvedAt": resolvedAt,
      "deletedAt": deletedAt,
      "category": category,
      "createdAt": id,
    };
  }

  @override
  String toString() {
    return "Description: $description\nComplainees: $to\nScope: ${scope.name}}\nCategory: $category";
  }

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
    deletedAt = complaintData["deletedAt"] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(complaintData["deletedAt"]);
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
    // if (complaintData["resolved"] == null) {
    //   updateComplaint(this);
    // }
    // --------------
  }
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
  await firestore.doc('complaints/${complaint.id}').set(complaint.encode());
  return complaint;
}

/// updates an exisiting complaint or will create if complaint does not exists
Future<void> deleteComplaint(ComplaintData complaint) async {
  final bool isDeleted = complaint.deletedAt != null;
  final now = DateTime.now();
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
  final response = await firestore.doc('complaints/$id').get();
  if (!response.exists) throw "Complaint Doesn't exists";
  final data = response.data();
  if (data == null) throw "Data not found";
  return ComplaintData.load(id, data);
}

/// fetches all complaints
Future<List<ComplaintData>> fetchComplaints({
  Source? src,
  bool resolved = false,
  int startID = infDateMillisec,
  int? limit,
}) async {
  // Fetching all public complaints
  final publicComplaints = await firestore
      .collection('complaints')
      .where('scope', isEqualTo: 'public')
      .where('resolved', isEqualTo: resolved)
      .where('deletedAt', isNull: true)
      .get(src != null ? GetOptions(source: src) : null);
  List<ComplaintData> ans = publicComplaints.docs
      .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
      .toList();
  // Fetching Private Complaints made by the user itself
  final myComplaints = await firestore
      .collection('complaints')
      .where('from', isEqualTo: currentUser.email)
      .where('scope', isEqualTo: 'private')
      .where('resolved', isEqualTo: resolved)
      .where('deletedAt', isNull: true)
      .get(src != null ? GetOptions(source: src) : null);
  ans += myComplaints.docs
      .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
      .toList();
  // Fetching all complaints in which the user is included
  final includedComplaints = await firestore
      .collection('complaints')
      .where('to', arrayContains: currentUser.email)
      .where('scope', isEqualTo: 'private')
      .where('resolved', isEqualTo: resolved)
      .where('deletedAt', isNull: true)
      .get(src != null ? GetOptions(source: src) : null);
  ans += includedComplaints.docs
      .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
      .toList();
  ans.sort((a, b) => (a.id < b.id) ? 1 : 0);
  return ans;
}

/// A widget used to display a child widget using a list of Complaints
class ComplaintsBuilder extends ConsumerWidget {
  final Widget Function(BuildContext ctx, List<ComplaintData> complaints)
      builder;
  final Future<List<ComplaintData>> Function({Source? src})? complaintsProvider;
  final Source? src;
  final Widget? loadingWidget;
  const ComplaintsBuilder({
    super.key,
    this.complaintsProvider,
    required this.builder,
    this.loadingWidget,
    this.src,
  });

  /// Use this to store data
  static List<ComplaintData> complaints = const [];

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(complaintBuilderSwitch);
    return FutureBuilder(
      future: complaintsProvider != null
          ? complaintsProvider!(src: src)
          : fetchComplaints(src: src),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error.toString();
        }
        if (!snapshot.hasData) {
          if (src == Source.cache) {
            return complaints.isEmpty && loadingWidget != null
                ? loadingWidget!
                : builder(context, complaints);
          }
          return FutureBuilder(
            future: complaintsProvider != null
                ? complaintsProvider!(src: src)
                : fetchComplaints(src: Source.cache),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                // Returning this Widget when nothing has arrived
                return complaints.isEmpty && loadingWidget != null
                    ? loadingWidget!
                    : builder(context, complaints);
              }
              // Returning this widget from cache while data arrives from server
              ComplaintsBuilder.complaints = snapshot.data!;
              return builder(ctx, complaints);
            },
          );
        }
        // Returning this widget when data arrives from server
        ComplaintsBuilder.complaints = snapshot.data!;
        return builder(ctx, complaints);
      },
    );
  }
}

final complaintBuilderSwitch = createSwitch();
