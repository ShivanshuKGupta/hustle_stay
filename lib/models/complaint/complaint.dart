import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/state_switch.dart';

enum Scope {
  public,
  private,
}

class ComplaintData {
  String? description;
  late String from;
  late String id;
  // createdAt dateTime object converted into a string or integer
  late Scope scope;
  late String title;
  late List<String> to;
  late bool resolved;
  String? imgUrl;

  ComplaintData({
    this.description = "",
    required this.from,
    required this.id,
    this.scope = Scope.public,
    required this.title,
    required this.to,
    required this.resolved,
    this.imgUrl,
  });

  Map<String, dynamic> encode() {
    return {
      "description": description,
      "from": from,
      "scope": scope.name,
      "title": title,
      "to": to,
      "resolved": resolved,
      "imgUrl": imgUrl,
    };
  }

  @override
  String toString() {
    return "Title: $title\nDescription: $description\nComplainees: $to\nScope: ${scope.name}}";
  }

  String operator -(ComplaintData oldComplaint) {
    String ans = "";
    bool addAnd = false;
    if (oldComplaint.title != title) {
      ans += '\nTitle to \'$title\'';
      addAnd = true;
    }
    if (oldComplaint.description != description) {
      ans += (addAnd ? " and " : '');
      ans += '\nDescription to \'$description\'';
    }
    if (!equalList(oldComplaint.to, to)) {
      ans += (addAnd ? " and " : '');
      ans += '\nComplainees to $to';
    }
    if (oldComplaint.scope != scope) {
      ans += (addAnd ? " and " : '');
      ans += '\nScope to ${scope.name}';
    }
    if (oldComplaint.imgUrl != imgUrl) {
      ans += (addAnd ? " and " : '');
      ans += '\nImageUrl to $imgUrl';
    }
    return ans;
  }

  /// Converts a Map<String, dynamic> to a Complaint Object
  ComplaintData.load(this.id, Map<String, dynamic> complaintData) {
    description = complaintData["description"];
    from = complaintData["from"];
    scope = Scope.values
        .firstWhere((element) => element.name == complaintData["scope"]);
    title = complaintData["title"];
    resolved = complaintData["resolved"] ?? false;
    imgUrl = complaintData["imgUrl"];
    to = (complaintData["to"] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
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
Future<void> updateComplaint(ComplaintData complaint) async {
  await firestore.doc('complaints/${complaint.id}').set(complaint.encode());
}

/// updates an exisiting complaint or will create if complaint does not exists
Future<void> deleteComplaint({ComplaintData? complaint, String? id}) async {
  assert(complaint != null || id != null);
  await firestore.doc('complaints/${id ?? complaint!.id}').delete();
}

/// fetches a complaint of given ID
Future<ComplaintData> fetchComplaint(String id) async {
  final response = await firestore.doc('complaints/$id').get();
  if (!response.exists) throw "Complaint Doesn't exists";
  final data = response.data();
  if (data == null) throw "Data not found";
  return ComplaintData.load(id, data);
}

/// fetches all complaints
Future<List<ComplaintData>> fetchComplaints(
    {Source? src, bool resolved = false}) async {
  // Fetching all public complaints
  final publicComplaints = await firestore
      .collection('complaints')
      .where('scope', isEqualTo: 'public')
      .where('resolved', isEqualTo: resolved)
      .get(src != null ? GetOptions(source: src) : null);
  List<ComplaintData> ans = publicComplaints.docs
      .map((e) => ComplaintData.load(e.id, e.data()))
      .toList();
  // Fetching Private Complaints made by the user itself
  final myComplaints = await firestore
      .collection('complaints')
      .where('from', isEqualTo: currentUser.email)
      .where('scope', isEqualTo: 'private')
      .where('resolved', isEqualTo: resolved)
      .get(src != null ? GetOptions(source: src) : null);
  ans +=
      myComplaints.docs.map((e) => ComplaintData.load(e.id, e.data())).toList();
  // Fetching all complaints in which the user is included
  final includedComplaints = await firestore
      .collection('complaints')
      .where('to', arrayContains: currentUser.email)
      .where('scope', isEqualTo: 'private')
      .where('resolved', isEqualTo: resolved)
      .get(src != null ? GetOptions(source: src) : null);
  ans += includedComplaints.docs
      .map((e) => ComplaintData.load(e.id, e.data()))
      .toList();
  ans.sort((a, b) => (int.parse(a.id) < int.parse(b.id)) ? 1 : 0);
  return ans;
}

/// A widget used to display a child widget using a list of Complaints
class ComplaintsBuilder extends ConsumerWidget {
  final Widget Function(BuildContext ctx, List<ComplaintData> complaints)
      builder;
  final Source? src;
  final Widget? loadingWidget;
  const ComplaintsBuilder({
    super.key,
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
      future: fetchComplaints(src: src),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          if (src == Source.cache) {
            return loadingWidget ?? builder(ctx, complaints);
          }
          return FutureBuilder(
            future: fetchComplaints(src: Source.cache),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                // Returning this Widget when nothing has arrived
                return complaints.isEmpty && loadingWidget != null
                    ? loadingWidget!
                    : builder(ctx, complaints);
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
