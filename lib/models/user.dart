import 'dart:convert';

import 'package:hustle_stay/tools/user_tools.dart';

import 'permissions.dart';

enum UserType {
  admin,
  warden,
  attender,
  student,
}

class User {
  String? rollNo;
  String? password;
  String? name;
  String? img;
  String? email;
  UserType? type;
  String? hostel;
  String? room;
  String? phone;
  Permissions? permissions;

  User({
    this.rollNo,
    this.password,
    this.name,
    this.img,
    this.email,
    this.type,
    this.hostel,
    this.room,
    this.phone,
    this.permissions,
  });

  String encode() {
    return json.encode(
      {
        "id": rollNo,
        "password": password,
        "name": name,
        "img": img,
        "email": email,
        "type": type != null ? type!.name : "null",
        "hostel": hostel,
        "room": room,
        "phone": phone,
        "permissions": permissions != null ? permissions!.encode() : "null",
      },
    );
  }
}

final currentUser = User();
