import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'hostel/rooms/room.dart';

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

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
  if (documentSnapshot.exists) {
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

Future<Map<String, double>> getAttendanceStatistics(
    String email, String hostelName, String roomName,
    {DateTimeRange? range}) async {
  double presentData = 0;
  double absentData = 0;
  double leaveData = 0;
  double internshipData = 0;

  final storage = FirebaseFirestore.instance;
  final docsAttendanceRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommates')
      .doc(email)
      .collection('Attendance')
      .get();
  for (final docs in docsAttendanceRef.docs) {
    if (range == null ||
        (DateFormat('yyyy-MM-dd')
                    .format(range.start)
                    .compareTo(docs.id.toString()) <=
                0 &&
            DateFormat('yyyy-MM-dd')
                    .format(range.end)
                    .compareTo(docs.id.toString()) >=
                0)) {
      switch (docs['status']) {
        case 'present':
          presentData += 1;
          break;
        case 'absent':
          absentData += 1;
          break;
        case 'onLeave':
          leaveData += 1;
          break;
        default:
          internshipData += 1;
      }
    }
  }
  Map<String, double> attendanceStats = {
    'present': presentData,
    'absent': absentData,
    'leave': leaveData,
    'internship': internshipData
  };

  return attendanceStats;
}

Future<Map<String, double>> getHostelAttendanceStatistics(
    String hostelName, DateTime date) async {
  double presentData = 0;
  double absentData = 0;
  double leaveData = 0;
  double internshipData = 0;

  final storage = FirebaseFirestore.instance;
  final docsRoomsRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .get();
  for (final roomDoc in docsRoomsRef.docs) {
    final roommateDocs = await roomDoc.reference.collection('Roommates').get();
    for (final roommateDoc in roommateDocs.docs) {
      final attendance = await roommateDoc.reference
          .collection('Attendance')
          .doc(DateFormat('yyyy-MM-dd').format(date))
          .get();
      if (attendance.exists) {
        switch (attendance['status']) {
          case 'present':
            presentData += 1;
            break;
          case 'absent':
            absentData += 1;
            break;
          case 'onLeave':
            leaveData += 1;
            break;
          default:
            internshipData += 1;
        }
      }
    }
  }

  Map<String, double> attendanceStats = {
    'present': presentData,
    'absent': absentData,
    'leave': leaveData,
    'internship': internshipData
  };

  return attendanceStats;
}
