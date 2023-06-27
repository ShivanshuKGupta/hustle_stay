import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user.dart';

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
