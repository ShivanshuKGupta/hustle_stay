import 'dart:convert';
import 'package:http/http.dart' as https;

import 'package:hustle_stay/tools/tools.dart';
import 'package:hustle_stay/tools/user_tools.dart';

class AttendanceSheet {
  // String? title;
  Map<String, bool> studentIDList; // = {}
  AttendanceSheet({this.studentIDList = const {}});

  String encode() {
    return json.encode(studentIDList);
  }
}

AttendanceSheet decodeAsAttendanceSheet(Map<String, dynamic> details) {
  var newSheet = AttendanceSheet();
  newSheet.studentIDList = {};
  details.forEach((key, value) {
    newSheet.studentIDList[key] = value;
  });
  return newSheet;
}

AttendanceSheet createAttendanceSheet(DateTime dateTime, String hostelID) {
  AttendanceSheet newSheet = AttendanceSheet();
  newSheet.studentIDList = {};
  for (final user in allUsers) {
    if (user.hostel == hostelID) newSheet.studentIDList[user.rollNo!] = false;
  }
  return newSheet;
}

Future<void> fetchAttendanceSheet(DateTime dateTime, String hostelID) async {
  final url = Uri.https("hustlestay-default-rtdb.firebaseio.com",
      "attendance/$hostelID/${convertDate(dateTime)}.json");
  final response = await https.get(url);
  if (response.body == "null") {
    currentSheet.studentIDList = {};
    return;
  }
  print(response.body);
  Map<String, dynamic> m = json.decode(response.body);
  print(m.values.first);
  Map<String, dynamic> studentID = m.values.first;
  AttendanceSheet ans = decodeAsAttendanceSheet(studentID);
  currentSheet = ans;
}

uploadAttendanceSheet(
    DateTime dateTime, AttendanceSheet sheet, String hostelID) async {
  final url = Uri.https("hustlestay-default-rtdb.firebaseio.com",
      "attendance/$hostelID/${convertDate(dateTime)}.json");
  final response = await https.post(url, body: sheet.encode());
  print(response.body);
}

AttendanceSheet currentSheet = AttendanceSheet();
