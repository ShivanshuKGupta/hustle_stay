import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  print(store);
  await store.doc('hostels/${hostel.hostelName}').set({
    "hostelName": hostel.hostelName,
    "hostelType": hostel.hostelType,
    "numberOfRooms": hostel.numberOfRooms,
    "numberOfFloorsorBlocks": hostel.numberOfFloorsorBlocks,
    "capacity": hostel.capacity
  });
}

Future<List<DropdownMenuItem>> fetchHostelNames({Source? src}) async {
  List<DropdownMenuItem> list = [];
  final storage = FirebaseFirestore.instance;
  final storageRef = await storage
      .collection('hostels')
      .get(src == null ? null : GetOptions(source: src));
  storageRef.docs.forEach((element) {
    list.add(DropdownMenuItem(
      child: Text(element.id),
      value: element.id,
    ));
  });
  return list;
}

Future<bool> deleteHostel(String hostelName) async {
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
