import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendNotification({
  String? title,
  String? body,
  required String to,
  Map<String, dynamic> data = const {},
}) async {
  /// TODO: Dangerous!!! the fcm API key is here and should be moved to a backend
  /// ERR:
  const String serverKey =
      'AAAAmUIGOT0:APA91bEVQn5IIBwUrIG8Brgf3vzZ-KxaGnDYY_8ElgZq65t909kx_EzFz6l613Kny_4Jh0JTcbm-EE3dvWGWM7dMISwseQ_wF0iYPDX9ti-nJKqrxKOXt3sKtXWh-VXSX_e3fsapadQO';
  const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  final Map<String, dynamic> notification = {
    'to': to,
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
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}
