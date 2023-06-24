import 'package:cloud_firestore/cloud_firestore.dart';
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

  ComplaintData({
    this.description = "",
    required this.from,
    required this.id,
    this.scope = Scope.public,
    required this.title,
    required this.to,
  });

  Map<String, dynamic> encode() {
    return {
      "description": description,
      "from": from,
      "scope": scope.name,
      "title": title,
      "to": to,
    };
  }

  /// Converts a Map<String, dynamic> to a Complaint Object
  ComplaintData.convert(this.id, Map<String, dynamic> complaintData) {
    description = complaintData["description"];
    from = complaintData["from"];
    scope = Scope.values
        .firstWhere((element) => element.name == complaintData["scope"]);
    title = complaintData["title"];
    to = (complaintData["to"] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
  }
}

/// updates an exisiting complaint or will create if complaint does not exists
Future<ComplaintData> addComplaint(ComplaintData complaint) async {
  final store = FirebaseFirestore.instance;
  String id = DateTime.now().microsecondsSinceEpoch.toString();
  complaint.id = id;
  await store.doc('complaints/$id').set(complaint.encode());
  return complaint;
}

/// updates an exisiting complaint or will create if complaint does not exists
Future<void> updateComplaint(String id, ComplaintData complaint) async {
  final store = FirebaseFirestore.instance;
  await store.doc('complaints/$id').set(complaint.encode());
}

/// fetches a complaint of given ID
Future<ComplaintData> fetchComplaint(String id) async {
  final store = FirebaseFirestore.instance;
  final response = await store.doc('complaints/$id').get();
  if (!response.exists) throw "Complaint Doesn't exists";
  final data = response.data();
  if (data == null) throw "Data not found";
  return ComplaintData.convert(id, data);
}

/// fetches all complaints
Future<List<ComplaintData>> fetchComplaints({Source? src}) async {
  final store = FirebaseFirestore.instance;
  // Fetching all public complaints
  final publicComplaints = await store
      .collection('complaints')
      .where('scope', isEqualTo: 'public')
      .get(src != null ? GetOptions(source: src) : null);
  List<ComplaintData> ans = publicComplaints.docs
      .map((e) => ComplaintData.convert(e.id, e.data()))
      .toList();
  // Fetching Private Complaints made by the user itself
  final myComplaints = await store
      .collection('complaints')
      .where('from', isEqualTo: currentUser.email)
      .where('scope', isEqualTo: 'private')
      .get(src != null ? GetOptions(source: src) : null);
  ans += myComplaints.docs
      .map((e) => ComplaintData.convert(e.id, e.data()))
      .toList();
  // Fetching all complaints in which the user is included
  final includedComplaints = await store
      .collection('complaints')
      .where('to', arrayContains: currentUser.email)
      .where('scope', isEqualTo: 'private')
      .get(src != null ? GetOptions(source: src) : null);
  ans += includedComplaints.docs
      .map((e) => ComplaintData.convert(e.id, e.data()))
      .toList();
  ans.sort((a, b) => (int.parse(a.id) < int.parse(b.id)) ? 1 : 0);
  return ans;
}
