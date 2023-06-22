import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateData {
  String name;
  String email;
  String rollNumber;
  RoommateData({
    required this.name,
    required this.email,
    required this.rollNumber,
  });
}

class Room {
  int numberOfRoommates;
  String roomName;
  int capacity;
  List<RoommateData>? roomMatesData;

  Room({
    required this.numberOfRoommates,
    required this.roomName,
    required this.capacity,
    required this.roomMatesData,
  });
}

Future<List<Room>> fetchRooms(String hostelName) async {
  List<Room> roomDataList = [];
  final storage = FirebaseFirestore.instance;

  final roomSnapshot = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .get();
  final roomDocs = roomSnapshot.docs;
  print(roomDocs.length);
  for (int i = 0; i < roomSnapshot.docs.length; i++) {
    print(roomDocs[i]);
    print(roomDocs[i]['capacity']);
    print(roomDocs[i]['roomName']);
    final roomRef = roomDocs[i].reference;
    final roommatesSnapshot = await roomRef.collection('Roommates').get();
    print('done here');
    if (roommatesSnapshot.docs.isNotEmpty) {
      final List<RoommateData> roommatesData = [];
      for (var roommateDoc in roommatesSnapshot.docs) {
        print(roommateDoc['email']);
        final roommateData = RoommateData(
          name: roommateDoc['name'],
          email: roommateDoc['email'],
          rollNumber: roommateDoc['rollNumber'],
        );
        roommatesData.add(roommateData);
      }

      final roomData = Room(
        capacity: roomDocs[i]['capacity'],
        numberOfRoommates: roomDocs[i]['numRoommates'],
        roomName: roomDocs[i]['roomName'],
        roomMatesData: roommatesData,
      );
      print("reached here too");
      roomDataList.add(roomData);
      print(roomDataList);
    } else {
      print("reached else part ");
      final roomData = Room(
        capacity: roomDocs[i]['capacity'],
        numberOfRoommates: roomDocs[i]['numRoommates'],
        roomName: roomDocs[i]['roomName'],
        roomMatesData: [],
      );
      roomDataList.add(roomData);
      print("reached end");
    }
  }
  print(roomDataList);
  return roomDataList;
}

Future<bool> isRoomExists(String hostelName, String roomName) async {
  final storage = FirebaseFirestore.instance;
  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .get();
  return storageRef.exists;
}

Future<bool> deleteRoom(String roomName, String hostelName) async {
  try {
    final storage = FirebaseFirestore.instance;
    final storageRef = await storage
      ..collection('hostels')
          .doc(hostelName)
          .collection('Rooms')
          .doc(roomName)
          .delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> changeRoom(String email, String hostelName, String roomName,
    String destHostelName, String destRoomName) async {
  try {
    final storage = FirebaseFirestore.instance;
    final sourceRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName)
        .collection('Roommates')
        .doc(email);
    final sData = await sourceRef.get();
    final destLoc = await storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Rooms')
        .doc(destRoomName)
        .collection('Roommates');
    final sourceData = sData.data();
    await destLoc.doc(email).set(sourceData!);
    sourceRef.delete();
    return true;
  } catch (e) {
    return false;
  }
}
