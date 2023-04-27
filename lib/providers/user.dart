import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:http/http.dart" as https;

enum UserType {
  admin,
  warden,
  attender,
  student,
}

class Permissions{
  bool canTakeAttendance,
  canModifyUsers,
  canRegisterComplaint,
  canModifyComplaints;
}

class User {
  String? rollNo; // Roll Number
  String? password;
  String? name, img;
  String? email;
  UserType type;
  String? hostel;
  String? room;
  String? phone;
  Permissions

  User(
      {this.rollNo,
      this.name,
      required this.type,
      this.hostel,
      this.room,
      this.password});

  String encode() {
    return json.encode({
      "name": name,
      "type": type.name,
      "hostel": hostel,
      "room": room,
      "password": password,
    });
  }
}

User decodeAsUser(String response) {
  Map<String, dynamic> details = json.decode(response);
  details = details.values.firstWhere((element) => true);
  return User(
    rollNo: details['id'],
    type: UserType.values
        .firstWhere((element) => element.name == details['type']),
    name: details['name'],
    hostel: details['hostel'],
    room: details['room'],
    password: details['password'],
  );
}

addUser(User user) async {
  final url = Uri.https(
      "hustlestay-default-rtdb.firebaseio.com", "users/${user.rollNo}.json");
  final response = await https.post(url, body: user.encode());
  print(response.body);
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User(type: UserType.student));

  Future<void> getDetails(User user) async {
    final url = Uri.https(
        "hustlestay-default-rtdb.firebaseio.com", "users/${user.rollNo}.json");
    final response = await https.get(url);
    if (response.body == 'null') {
      throw "User not found";
    }
    print(response.body);
    User matchedUser = decodeAsUser(response.body);
    if (matchedUser.password != user.password) {
      throw "Invalid Password";
    }
    state = matchedUser;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
