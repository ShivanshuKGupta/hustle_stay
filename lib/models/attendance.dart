import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<bool> getAttendanceData(
    String email, String hostelName, String roomName, DateTime date) async {
  final storage = FirebaseFirestore.instance;
  final documentRef = storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommates')
      .doc(email)
      .collection('Attendance')
      .doc(DateFormat('dd-MM-yyyy').format(date));

  final documentSnapshot = await documentRef.get();

  if (documentSnapshot.exists) {
    return documentSnapshot['isPresent'];
  } else {
    await documentRef.set({'isPresent': false});
    return false;
  }
}

Future<bool> setAttendanceData(String email, String hostelName, String roomName,
    DateTime date, bool status) async {
  try {
    final storage = FirebaseFirestore.instance;
    final docRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName)
        .collection('Roommates')
        .doc(email)
        .collection('Attendance')
        .doc(DateFormat('dd-MM-yyyy').format(date));

    await storage.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'isPresent': !status});
      } else {
        transaction.update(docRef, {'isPresent': !status});
      }
    });

    return true;
  } catch (e) {
    // Handle the error, log or display an error message if needed
    print('Error while setting attendance data: $e');
    return false;
  }
}
