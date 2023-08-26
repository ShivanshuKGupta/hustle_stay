import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hustle_stay/models/user/user.dart';

Future<void> sendNotification({
  String? title,
  String? body,
  required String toEmail,
  Map<String, dynamic> data = const {},
}) async {
  /// TODO: Dangerous!!! the fcm API key is here and should be moved to a backend
  /// ERR:
  const String serverKey =
      'AAAAmUIGOT0:APA91bEVQn5IIBwUrIG8Brgf3vzZ-KxaGnDYY_8ElgZq65t909kx_EzFz6l613Kny_4Jh0JTcbm-EE3dvWGWM7dMISwseQ_wF0iYPDX9ti-nJKqrxKOXt3sKtXWh-VXSX_e3fsapadQO';
  const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  final user = await fetchUserData(toEmail, src: Source.serverAndCache);
  if (user.fcmToken == null) {
    debugPrint("fcmToken not found for user '$toEmail'");
    return;
  }

  final Map<String, dynamic> notification = {
    'to': user.fcmToken,
    'data': data,
    'notification': {
      'title': title,
      'body': body,
    },
  };

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: headers,
    body: jsonEncode(notification),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully to $toEmail');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}
