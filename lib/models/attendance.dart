import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<bool> getAttendanceData(
    String email, String hostelName, String roomName, DateTime date) async {
  final storage = FirebaseFirestore.instance;
  final data = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommmates')
      .doc(email)
      .collection('Attendance')
      .doc(DateFormat('dd-MM-yyyy').format(date))
      .get();
  if (data.exists && data['isPresent']) {
    return true;
  }
  return false;
}

Future<bool> setAttendanceData(String email, String hostelName, String roomName,
    DateTime date, bool status) async {
  final storage = FirebaseFirestore.instance;
  final data = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommmates')
      .doc(email)
      .collection('Attendance')
      .doc(DateFormat('dd-MM-yyyy').format(date))
      .set({'isPresent': !status}, SetOptions(merge: true));
  return true;
}
