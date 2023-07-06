import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'hostel/rooms/room.dart';

Future<String> getAttendanceData(RoommateData roommateData, String hostelName,
    String roomName, DateTime date) async {
  final storage = FirebaseFirestore.instance;
  final documentRef = storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommates')
      .doc(roommateData.email)
      .collection('Attendance')
      .doc(DateFormat('yyyy-MM-dd').format(date));

  if (roommateData.onLeave != null &&
      roommateData.onLeave! &&
      roommateData.leaveStartDate != null &&
      (roommateData.leaveStartDate!.isBefore(date)) &&
      roommateData.leaveEndDate != null &&
      (roommateData.leaveEndDate!.isAfter(date))) {
    await documentRef.set({'status': 'onLeave'}, SetOptions(merge: false));
    return 'onLeave';
  }

  final documentSnapshot = await documentRef.get();
  if (documentSnapshot.exists &&
      documentSnapshot['status'] != 'onLeave' &&
      documentSnapshot['status'] != 'internship') {
    return documentSnapshot['status'];
  } else {
    await documentRef.set({'status': 'absent'});
    return 'absent';
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
        .doc(DateFormat('yyyy-MM-dd').format(date));

    await storage.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'status': status ? 'absent' : 'present'});
      } else {
        transaction.update(docRef, {'status': status ? 'absent' : 'present'});
      }
    });

    return true;
  } catch (e) {
    print('Error while setting attendance data: $e');
    return false;
  }
}

Future<bool> markAllAttendance(
    String hostelName, bool status, DateTime selectedDate) async {
  try {
    String statusVal = status ? 'present' : 'absent';
    final storage = FirebaseFirestore.instance;
    final docsRoomsRef = await storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .get();
    final batch = storage.batch();
    for (final roomDoc in docsRoomsRef.docs) {
      final roommateDocs =
          await roomDoc.reference.collection('Roommates').get();
      for (final roommateDoc in roommateDocs.docs) {
        final attendanceRef = roommateDoc.reference
            .collection('Attendance')
            .doc(DateFormat('yyyy-MM-dd').format(selectedDate));
        batch.set(
          attendanceRef,
          {'status': statusVal},
          SetOptions(merge: true),
        );
      }
    }
    await batch.commit();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> markAllRoommateAttendance(String hostelName, String roomName,
    bool status, DateTime selectedDate) async {
  try {
    String statusVal = status ? 'present' : 'absent';
    final storage = FirebaseFirestore.instance;
    final docsRoommatesRef = await storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName)
        .collection('Roommates')
        .get();
    final batch = storage.batch();
    for (final roommateDoc in docsRoommatesRef.docs) {
      final attendanceRef = roommateDoc.reference
          .collection('Attendance')
          .doc(DateFormat('yyyy-MM-dd').format(selectedDate));
      batch.set(
        attendanceRef,
        {'status': statusVal},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    return true;
  } catch (e) {
    return false;
  }
}
