import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hustle_stay/models/room.dart';
import 'package:http/http.dart' as https;

class Hostel {
  String name;
  String description;
  Image? img;
  List<Room> rooms;
  Hostel({
    this.name = "",
    this.description = "",
    this.rooms = const [],
    this.img,
  });

  String encode() {
    // List<String> roomList = rooms.map((room) => room.encode()).toList();
    return json.encode(
      {
        "name": name,
        "description": description,
        "img": img,
        // "rooms": json.encode(roomList),
      },
    );
  }
}

Hostel decodeAsHostel(Map details) {
  return Hostel(
    name: details["name"],
    description: details["description"],
    img: details["img"],
    // rooms: json.decode(details["rooms"]),
  );
}

Future<List<Hostel>> fetchHostels() async {
  final url =
      Uri.https("hustlestay-default-rtdb.firebaseio.com", "hostel_list.json");
  final response = await https.get(url);
  Map<String, dynamic> m = json.decode(response.body);
  List<Hostel> ans = [];
  m.forEach((key, value) => ans.add(decodeAsHostel(value)));
  return ans;
}

uploadHostel(Hostel hostel) async {
  final url =
      Uri.https("hustlestay-default-rtdb.firebaseio.com", "hostel_list.json");
  final response = await https.post(url, body: hostel.encode());
  print(response.body);
}
