import 'dart:convert';
import 'package:http/http.dart' as https;

import 'package:hustle_stay/models/room.dart';
import 'package:hustle_stay/tools/tools.dart';

class AttendanceSheet {
  String? title;
  List<Room> roomList = [];
  AttendanceSheet({this.title, this.roomList = const []});

  String encode() {
    return json.encode({"title": title, "roomList": roomList});
  }
}

AttendanceSheet decodeAsAttendanceSheet(Map details) {
  return AttendanceSheet(
      title: details['title'], roomList: details['roomList']);
}

AttendanceSheet createAttendanceSheet(DateTime dateTime) {
  return AttendanceSheet();
}

Future<AttendanceSheet> fetchAttendanceSheet(DateTime dateTime) async {
  final url = Uri.https("hustlestay-default-rtdb.firebaseio.com",
      "attendance/${convertDate(dateTime)}.json");
  final response = await https.get(url);
  Map<String, dynamic> m = json.decode(response.body);
  AttendanceSheet ans = m.values.firstWhere((element) => true);
  return ans;
}

uploadAttendanceSheet(DateTime dateTime, AttendanceSheet sheet) async {
  final url = Uri.https("hustlestay-default-rtdb.firebaseio.com",
      "attendance/${convertDate(dateTime)}.json");
  final response = await https.post(url, body: sheet.encode());
  print(response.body);
}
