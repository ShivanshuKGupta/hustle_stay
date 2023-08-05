import 'package:flutter/material.dart';

import '../hostel/hostels.dart';

class Operations {
  final String operationName;
  Icon? icon;
  Color cardColor;
  String? imgUrl;
  Hostels? hostel;
  Operations(
      {required this.cardColor,
      required this.operationName,
      this.icon,
      this.imgUrl,
      this.hostel});
}

class ColorLabel {
  final Color color;
  final String label;
  ColorLabel({required this.color, required this.label});
}
