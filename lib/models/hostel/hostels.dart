import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../attendance.dart';

// enum String {
//   boys,
//   girls,
//   coed,
// }

class Hostels {
  String hostelName;
  String hostelType;
  int capacity;
  int numberOfRooms;
  int numberOfFloorsorBlocks;
  String imageUrl;

  Hostels({
    required this.capacity,
    required this.hostelName,
    required this.hostelType,
    required this.numberOfRooms,
    required this.numberOfFloorsorBlocks,
    required this.imageUrl,
  });
}

Future<List<Hostels>> fetchHostels({Source? src}) async {
  List<Hostels> HostelDataList = [];
  final storage = FirebaseFirestore.instance;
  final hostelList = await storage
      .collection('hostels')
      .get(src != null ? GetOptions(source: src) : null);
  final listHostel = hostelList.docs.toList();
  for (int i = 0; i < listHostel.length; i++) {
    HostelDataList.add(Hostels(
      capacity: listHostel[i]['capacity'],
      hostelName: listHostel[i]['hostelName'],
      hostelType: listHostel[i]['hostelType'],
      numberOfRooms: listHostel[i]['numberOfRooms'],
      numberOfFloorsorBlocks: listHostel[i]['numberOfFloorsorBlocks'],
      imageUrl: listHostel[i]['imageUrl'],
    ));
  }

  return HostelDataList;
}

Future<void> uploadHostel(Hostels hostel) async {
  final store = FirebaseFirestore.instance;
  await store.doc('hostels/${hostel.hostelName}').set({
    "hostelName": hostel.hostelName,
    "hostelType": hostel.hostelType,
    "numberOfRooms": hostel.numberOfRooms,
    "numberOfFloorsorBlocks": hostel.numberOfFloorsorBlocks,
    "capacity": hostel.capacity
  });
}

Future<List<String>> fetchHostelNames({Source? src}) async {
  List<String> list = [];
  final storage = FirebaseFirestore.instance;
  final storageRef = await storage
      .collection('hostels')
      .get(src == null ? null : GetOptions(source: src));
  storageRef.docs.forEach((element) {
    list.add(element.id);
  });
  return list;
}

Future<bool> deleteHostel(String hostelName, bool isDisabled) async {
  try {
    await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelName)
        .delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> updateLeaveStatus(String email, String hostelName) async {
  final ref = await FirebaseFirestore.instance
      .collection('hostels')
      .doc('hostelMates')
      .collection('Roommates')
      .doc(email)
      .get();

  await ref.reference.set(
      {'onInternship': null, 'leaveStartDate': null, 'leaveEndDate': null},
      SetOptions(merge: true));

  return;
}

Future<bool> setLeave(
    String email, String hostelName, bool status, bool endleave,
    {DateTime? leaveStartDate,
    DateTime? leaveEndDate,
    String? reason,
    LeaveData? data,
    DateTime? selectedDate}) async {
  try {
    final ref = await FirebaseFirestore.instance
        .collection('hostels')
        .doc('hostelMates')
        .collection('Roommates')
        .doc(email)
        .get();
    if (endleave) {
      final startDate = ref.data()!['leaveStartDate'];
      final endDate = ref.data()!['leaveEndDate'];
      final updateLeavepath = await ref.reference
          .collection('Leaves')
          .where('startDate', isEqualTo: startDate)
          .where('endDate', isEqualTo: endDate)
          .limit(1)
          .get();
      if (updateLeavepath.size > 0) {
        final updateLeaveRef = updateLeavepath.docs.single.reference;
        updateLeaveRef
            .set({'endDate': DateTime.now()}, SetOptions(merge: true));
      }
      ref.reference.set(
          {'onInternship': false, 'leaveStartDate': null, 'leaveEndDate': null},
          SetOptions(merge: true));
      if (DateTime.now().isBefore(endDate.toDate())) {
        await ref.reference
            .collection('Attendance')
            .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .set({'status': 'absent'}, SetOptions(merge: true));
      }
      return true;
    } else if (data != null) {
      final updateLeavepath = await ref.reference
          .collection('Leaves')
          .where('startDate', isEqualTo: data.startDate)
          .where('endDate', isEqualTo: data.endDate)
          .limit(1)
          .get();
      if (updateLeavepath.size > 0) {
        final updateLeaveRef = updateLeavepath.docs.single.reference;
        updateLeaveRef.set(
            {'startDate': leaveStartDate, 'endDate': leaveEndDate},
            SetOptions(merge: true));
      }
      ref.reference.set(
          {'leaveStartDate': leaveStartDate, 'leaveEndDate': leaveEndDate},
          SetOptions(merge: true));
      if (DateTime.now().isAfter(leaveEndDate!)) {
        await ref.reference
            .collection('Attendance')
            .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .set({'status': 'absent'}, SetOptions(merge: true));
      }
    } else {
      await ref.reference.collection('Leaves').doc().set({
        'startDate': leaveStartDate,
        'endDate': leaveEndDate,
        'leaveType': reason
      });

      ref.reference.set({
        'onInternship': reason == "Internship",
        'leaveStartDate': leaveStartDate,
        'leaveEndDate': leaveEndDate
      }, SetOptions(merge: true));
    }
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
