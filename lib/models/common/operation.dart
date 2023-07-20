import 'package:flutter/material.dart';

class Operations {
  final String operationName;
  Icon? icon;
  Color cardColor;
  String? imgUrl;
  Operations(
      {required this.cardColor,
      required this.operationName,
      this.icon,
      this.imgUrl});
}
