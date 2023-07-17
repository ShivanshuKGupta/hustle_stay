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

class LeaveData {
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType;
  LeaveData(this.startDate, this.endDate, this.leaveType);
}

class RoommateInfo {
  final RoommateData roommateData;
  final String roomName;

  RoommateInfo({
    required this.roomName,
    required this.roommateData,
  });
}

Future<String> getAttendanceData(RoommateData roommateData, String hostelName,
    String roomName, DateTime date) async {
  final storage = FirebaseFirestore.instance;
  final documentRef = storage
      .collection('hostels')
      .doc(hostelName)
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
    String val =
        roommateData.internship != null && roommateData.internship == true
            ? 'onInternship'
            : 'onLeave';
    await documentRef.set({'status': val}, SetOptions(merge: false));
    return val;
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
    DateTime date, String status) async {
  try {
    final docRef = FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelName)
        .collection('Roommates')
        .doc(email)
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd').format(date));

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      transaction.set(
          docRef,
          {
            'status': (status == 'present' || status == 'presentLate')
                ? 'absent'
                : (DateTime.now()
                        .isAfter(DateTime(date.year, date.month, date.day, 23)))
                    ? 'presentLate'
                    : 'present',
          },
          SetOptions(merge: true));
    });

    return true;
  } catch (e) {
    debugPrint('Error while setting attendance data: $e');
    return false;
  }
}

Future<List<DateTime>> fetchAttendanceByStudent(
    String email, String hostelName, String status,
    {Source? source}) async {
  List<DateTime> list = [];

  final attendanceDataRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .doc(email)
      .collection('Attendance')
      .where('status', isEqualTo: status)
      .get(source == null ? null : GetOptions(source: source));
  final attendanceData = attendanceDataRef.docs;
  for (final doc in attendanceData) {
    List<String> dateComponents = doc.id.split('-');

    int year = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int day = int.parse(dateComponents[2]);
    list.add(DateTime(year, month, day));
  }

  return list;
}

Future<bool> markAllAttendance(
    String hostelName, bool status, DateTime selectedDate) async {
  try {
    final statusVal = status ? 'present' : 'absent';
    final storage = FirebaseFirestore.instance;
    final batch = storage.batch();
    final roommatesRef =
        storage.collection('hostels').doc(hostelName).collection('Roommates');

    QuerySnapshot<Map<String, dynamic>> roommatesQuery;
    if (DateTime(selectedDate.year, selectedDate.month, selectedDate.day) !=
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        )) {
      roommatesQuery = await roommatesRef.get();
    } else {
      roommatesQuery =
          await roommatesRef.where('onLeave', isNotEqualTo: true).get();
      final roommatesLeaveQuery =
          await roommatesRef.where('onLeave', isEqualTo: true).get();

      for (final x in roommatesLeaveQuery.docs) {
        final attendanceDocRef = x.reference
            .collection('Attendance')
            .doc(DateFormat('yyyy-MM-dd').format(selectedDate));

        if (x.data()['onInternship'] == true) {
          batch.set(attendanceDocRef, {'status': 'onInternship'});
        } else {
          batch.set(attendanceDocRef, {'status': 'onLeave'});
        }
      }
    }

    final attendanceFutures = roommatesQuery.docs.map((x) => x.reference
        .collection('Attendance')
        .where(FieldPath.documentId,
            isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
        .get());
    final attendanceSnapshots = await Future.wait(attendanceFutures);

    for (int i = 0; i < attendanceSnapshots.length; i++) {
      final attendanceSnapshot = attendanceSnapshots[i];

      if (attendanceSnapshot.size > 0) {
        final attendanceDoc = attendanceSnapshot.docs.first;

        if ((statusVal == 'present' &&
                attendanceDoc.data()['status'] == 'absent') ||
            (statusVal == 'absent' &&
                (attendanceDoc.data()['status'] == 'present' ||
                    attendanceDoc.data()['status'] == 'presentLate'))) {
          final attendanceDocRef = attendanceDoc.reference;
          if (statusVal == 'present' &&
              DateTime.now().isAfter(DateTime(selectedDate.year,
                  selectedDate.month, selectedDate.day, 23))) {
            batch.set(
              attendanceDocRef,
              {'status': 'presentLate'},
              SetOptions(merge: true),
            );
          } else {
            batch.set(
              attendanceDocRef,
              {'status': statusVal},
              SetOptions(merge: true),
            );
          }
        }
      } else {
        final attendanceDocRef =
            roommatesQuery.docs[i].reference.collection('Attendance');
        batch.set(
          attendanceDocRef.doc(DateFormat('yyyy-MM-dd').format(selectedDate)),
          {'status': statusVal},
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
        .collection('Roommates')
        .where('roomName', isEqualTo: roomName)
        .get();
    final batch = storage.batch();
    for (final roommateDoc in docsRoommatesRef.docs) {
      final attendanceRef = await roommateDoc.reference
          .collection('Attendance')
          .doc(DateFormat('yyyy-MM-dd').format(selectedDate))
          .get();
      if (attendanceRef.exists &&
          attendanceRef.data()!['status'] != 'onLeave' &&
          attendanceRef.data()!['status'] != 'internship') {
        batch.set(
          attendanceRef.reference,
          {
            'status': statusVal == 'present' &&
                    DateTime.now().isAfter(DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day, 23))
                ? 'presentLate'
                : statusVal
          },
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

Future<Map<String, double>> getAttendanceStatistics(
    String email, String hostelName,
    {DateTimeRange? range, Source? source}) async {
  double presentData = 0;
  double absentData = 0;
  double leaveData = 0;
  double internshipData = 0;
  double presentLateData = 0;
  double total = 0;

  final storage = FirebaseFirestore.instance;
  final docsAttendanceRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .doc(email)
      .collection('Attendance')
      .get();
  total = docsAttendanceRef.docs.length.toDouble();
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
        case 'presentLate':
          presentLateData += 1;
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
    'internship': internshipData,
    'presentLate': presentLateData,
    'total': total,
  };

  return attendanceStats;
}

Future<Map<String, double>> getHostelAttendanceStatistics(
    String hostelName, DateTime date,
    {Source? source}) async {
  final storage = FirebaseFirestore.instance;
  double total = 0;

  final roommatesQuery = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .get(source == null ? null : GetOptions(source: source));
  total = roommatesQuery.docs.length.toDouble();
  final List<Future<DocumentSnapshot<Map<String, dynamic>>>> attendanceFutures =
      [];

  for (final x in roommatesQuery.docs) {
    final attendanceRef = x.reference
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd').format(date));

    attendanceFutures.add(attendanceRef.get());
  }

  final List<DocumentSnapshot<Map<String, dynamic>>> attendanceSnapshots =
      await Future.wait(attendanceFutures);

  double present = 0;
  double absent = 0;
  double leave = 0;
  double internship = 0;
  double presentLate = 0;

  for (final attendanceSnapshot in attendanceSnapshots) {
    if (attendanceSnapshot.exists) {
      switch (attendanceSnapshot['status']) {
        case 'present':
          present += 1;
          break;
        case 'absent':
          absent += 1;
          break;
        case 'onLeave':
          leave += 1;
          break;
        case 'presentLate':
          presentLate += 1;
          break;
        default:
          internship += 1;
      }
    }
  }

  final attendanceStats = {
    'present': present,
    'presentLate': presentLate,
    'absent': absent,
    'leave': leave,
    'internship': internship,
    'total': total
  };

  return attendanceStats;
}

Future<List<RoommateInfo>> getFilteredStudents(
    String statusVal, DateTime date, String hostelName,
    {Source? source}) async {
  final storage = FirebaseFirestore.instance;

  final QuerySnapshot<Map<String, dynamic>> roommatesQuery = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .get(source == null ? null : GetOptions(source: source));

  final List<Future<QuerySnapshot<Map<String, dynamic>>>> attendanceFutures =
      [];

  for (final x in roommatesQuery.docs) {
    final attendanceQuery = x.reference
        .collection('Attendance')
        .where(FieldPath.documentId,
            isEqualTo: DateFormat('yyyy-MM-dd').format(date))
        .where('status', isEqualTo: statusVal)
        .get();

    attendanceFutures.add(attendanceQuery);
  }

  final List<QuerySnapshot<Map<String, dynamic>>> attendanceSnapshots =
      await Future.wait(attendanceFutures);

  final List<RoommateInfo> list = [];

  for (int i = 0; i < attendanceSnapshots.length; i++) {
    final QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
        attendanceSnapshots[i];
    if (attendanceSnapshot.size > 0) {
      final QueryDocumentSnapshot<Map<String, dynamic>> attendanceDoc =
          attendanceSnapshot.docs.first;

      if (attendanceDoc.exists) {
        final data = attendanceDoc.data();
        final onLeave = data['onLeave'] ?? false;
        final internship = data['internship'] ?? false;

        final leaveStartDate = data['leaveStartDate'] as Timestamp?;
        final leaveEndDate = data['leaveEndDate'] as Timestamp?;

        list.add(RoommateInfo(
          roomName: roommatesQuery.docs[i].data()['roomName'],
          roommateData: RoommateData(
            email: roommatesQuery.docs[i].id,
            onLeave: onLeave,
            leaveStartDate: leaveStartDate?.toDate(),
            leaveEndDate: leaveEndDate?.toDate(),
            internship: internship,
          ),
        ));
      }
    }
  }

  return list;
}

Future<LeaveData?> fetchCurrentLeave(String hostelName, String email) async {
  final refR = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .doc(email)
      .get();

  final leaveStartDate = refR.data()!['leaveStartDate'];
  final leaveEndDate = refR.data()!['leaveEndDate'];

  final ref = await refR.reference
      .collection('Leaves')
      .where('startDate', isEqualTo: leaveStartDate)
      .where('endDate', isEqualTo: leaveEndDate)
      .limit(1)
      .get();

  if (ref.size > 0) {
    return LeaveData(
      ref.docs[0].data()['startDate'].toDate(),
      ref.docs[0].data()['endDate'].toDate(),
      ref.docs[0].data()['leaveType'],
    );
  } else {
    return null;
  }
}

Future<List<LeaveData>> fetchLeaves(String hostelName, String email) async {
  final refR = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .doc(email)
      .get();

  final leaveStartDate = refR.data()!['leaveStartDate'];
  final onLeave = refR.data()!['onLeave'];

  final leavesRef = refR.reference.collection('Leaves');

  QuerySnapshot<Map<String, dynamic>> ref;

  if (onLeave == true) {
    ref =
        await leavesRef.where('startDate', isNotEqualTo: leaveStartDate).get();
  } else {
    ref = await leavesRef.get();
  }

  final list = ref.docs
      .map((x) => LeaveData(x.data()['startDate'].toDate(),
          x.data()['endDate'].toDate(), x.data()['leaveType']))
      .toList();

  // print('leave list: $list');
  return list;
}
