import 'package:cloud_firestore/cloud_firestore.dart';

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

Future<List<Hostels>> fetchHostels() async {
  List<Hostels> HostelDataList = [];
  final storage = FirebaseFirestore.instance;
  final hostelList = await storage.collection('hostels').get();
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

// final currentHostels = [
//   Hostels(
//       capacity: 48,
//       hostelName: 'Tungabhadra',
//       hostelType: String.girls,
//       numberOfRooms: 16,
//       numberOfFloorsorBlocks: 2),
//   Hostels(
//       capacity: 48,
//       hostelName: 'Krishna',
//       hostelType: String.boys,
//       numberOfRooms: 16,
//       numberOfFloorsorBlocks: 2),
//   Hostels(
//       capacity: 83,
//       hostelName: 'Federal',
//       hostelType: String.boys,
//       numberOfRooms: 13,
//       numberOfFloorsorBlocks: 2),
// ];

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

// void addHostel(String hostelName, String hostelType, int capacity,
//     int numberOfRooms, int numberOfFloorsorBlocks) {
//   currentHostels.add(Hostels(
//       capacity: capacity,
//       hostelName: hostelName,
//       hostelType: hostelType,
//       numberOfRooms: numberOfRooms,
//       numberOfFloorsorBlocks: numberOfFloorsorBlocks));
// }
