import 'dart:convert';

import 'package:http/http.dart' as https;

class Room {
  String name;
  List<String> students;
  Room({required this.name, required this.students});

  String encode() {
    return json.encode(
      {
        "name": name,
        "students": json.encode(students),
      },
    );
  }
}

Future<List<Room>> fetchAllRooms(String hostel) async {
  final url =
      Uri.https("hustlestay-default-rtdb.firebaseio.com", "$hostel.json");
  final response = await https.get(url);
  Map<String, dynamic> m = json.decode(response.body);
  List<Room> ans = [];
  m.forEach((key, value) => ans.add(decodeAsRoom(value)));
  return ans;
}

uploadRoom(String hostel, Room room) async {
  final url =
      Uri.https("hustlestay-default-rtdb.firebaseio.com", "$hostel.json");
  final response = await https.post(url, body: room.encode());
  print(response.body);
}

Room decodeAsRoom(Map details) {
  return Room(
    name: details['name'],
    students: details['students'],
  );
}
