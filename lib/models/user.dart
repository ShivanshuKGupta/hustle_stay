import 'package:flutter/material.dart';

enum UserType {
  admin,
  warden,
  attender,
  student,
}

class User {
  final String id; // Roll Number
  String name, img;
  UserType type;
  User(
      {required this.id,
      required this.name,
      required this.img,
      required this.type});
}
