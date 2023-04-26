import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, SnackBar snackBar) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showMsg(BuildContext context, String msg) {
  showSnackBar(
      context,
      SnackBar(
        content: Text(msg),
        showCloseIcon: true,
      ));
}
