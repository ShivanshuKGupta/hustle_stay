import 'dart:convert';
import 'package:http/http.dart' as https;

import 'package:hustle_stay/models/permissions.dart';
import '../models/user.dart';

// Fetches all users
Future<void> fetchAllUsers() async {
  final url = Uri.https("hustlestay-default-rtdb.firebaseio.com", "users.json");
  final response = await https.get(url);
  Map<String, dynamic> m = json.decode(response.body);
  List<User> ans = [];
  m.forEach((key, value) => ans.add(decodeAsUser(value)));
  allUsers = ans;
}

List<User> allUsers = [];

uploadUser(User user) async {
  final url = Uri.https("hustlestay-default-rtdb.firebaseio.com", "users.json");
  final response = await https.post(url, body: user.encode());
  print(response.body);
}

User decodeAsUser(Map details) {
  return User(
    rollNo: details['id'],
    password: details['password'],
    name: details['name'],
    img: details['img'],
    email: details['email'],
    type: UserType.values
        .firstWhere((element) => element.name == details['type']),
    hostel: details['hostel'],
    room: details['room'],
    phone: details['phone'],
    permissions: decodeAsPermissions(details['permissions']),
  );
}

void login(String id, String pwd) {
  print("Login called for $id , $pwd");
  final matchedUser = allUsers.firstWhere(
      (usr) => usr.rollNo!.toLowerCase() == id.toLowerCase(), orElse: () {
    return User(rollNo: "-1");
  });
  if (matchedUser.rollNo == "-1") throw "User not found";
  if (matchedUser.password != pwd) throw "Invalid Password";
  currentUser.rollNo = matchedUser.rollNo;
  currentUser.password = matchedUser.password;
  currentUser.name = matchedUser.name;
  currentUser.img = matchedUser.img;
  currentUser.email = matchedUser.email;
  currentUser.type = matchedUser.type;
  currentUser.hostel = matchedUser.hostel;
  currentUser.room = matchedUser.room;
  currentUser.phone = matchedUser.phone;
  currentUser.permissions = matchedUser.permissions;
}
