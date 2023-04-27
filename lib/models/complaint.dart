import "dart:convert";

import "package:http/http.dart" as https;

enum ComplaintType {
  cleaning,
  electricity,
  emergency,
  maintenance,
  water,
  other,
}

class Complaint {
  String? id;
  ComplaintType cType;
  String heading;
  String body;
  String location;
  String posterID;
  DateTime? entryTime;

  Complaint({
    required this.location,
    required this.cType,
    required this.heading,
    required this.posterID,
    required this.body,
    this.id,
    this.entryTime,
  });

  String encode() {
    return json.encode({
      "location": location,
      "cType": cType,
      "heading": heading,
      "posterID": posterID,
      "body": body,
      "entryTime": entryTime,
    });
  }
}

Complaint decodeAsComplaint(Map details) {
  return Complaint(
    location: details["location"],
    cType: details["cType"],
    heading: details["heading"],
    posterID: details["posterID"],
    body: details["body"],
    id: details["id"],
    entryTime: details["entryTime"],
  );
}

postComplaint(Complaint complaint) async {
  final url =
      Uri.https("hustlestay-default-rtdb.firebaseio.com", "complaints.json");
  final response = await https.post(url, body: complaint.encode());
  print(response.body);
  allComplaints.add(complaint);
}

Future<void> fetchAllComplaints() async {
  final url =
      Uri.https("hustlestay-default-rtdb.firebaseio.com", "complaints.json");
  final response = await https.get(url);
  Map<String, dynamic> m = json.decode(response.body);
  List<Complaint> ans = [];
  m.forEach((key, value) => ans.add(decodeAsComplaint(value)));
  allComplaints = ans;
  // state = response.body;
}

List<Complaint> allComplaints = [];
