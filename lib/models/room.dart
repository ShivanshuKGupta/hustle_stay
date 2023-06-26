import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

Future<List<Room>> fetchRooms(String hostelName, {Source? src}) async {
  List<Room> roomDataList = [];
  final storage = FirebaseFirestore.instance;

  final roomSnapshot = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .get(src != null ? GetOptions(source: src) : null);
  final roomDocs = roomSnapshot.docs;
  print(roomDocs.length);
  for (int i = 0; i < roomSnapshot.docs.length; i++) {
    print(roomDocs[i]);
    print(roomDocs[i]['capacity']);
    print(roomDocs[i]['roomName']);
    final roomRef = roomDocs[i].reference;
    final roommatesSnapshot = await roomRef
        .collection('Roommates')
        .get(src != null ? GetOptions(source: src) : null);
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
      roomDataList.add(roomData);
      print(roomDataList);
    } else {
      final roomData = Room(
        capacity: roomDocs[i]['capacity'],
        numberOfRoommates: roomDocs[i]['numRoommates'],
        roomName: roomDocs[i]['roomName'],
        roomMatesData: [],
      );
      roomDataList.add(roomData);
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
    final result = await storage.runTransaction((transaction) async {
      final storageRef = storage.collection('hostels').doc(hostelName);
      transaction
          .update(storageRef, {'numberOfRooms': FieldValue.increment(-1)});
      transaction.delete(storageRef.collection('Rooms').doc(roomName));
      // await storageRef.update({'numberOfRooms': FieldValue.increment(-1)});
      // await storageRef.collection('Rooms').doc(roomName).delete();
      return true;
    });
    if (result) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> changeRoom(String email, String hostelName, String roomName,
    String destHostelName, String destRoomName, BuildContext context) async {
  try {
    final storage = FirebaseFirestore.instance;
    final sourceRoomRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName);
    final sourceRef = sourceRoomRef.collection('Roommates').doc(email);
    final sData = await sourceRef.get();
    final destRoomLoc = await storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Rooms')
        .doc(destRoomName);
    if (await destRoomLoc.get().then((value) {
      return value['capacity'] > value['numRoommates'];
    })) {
      final destLoc = destRoomLoc.collection('Roommates');
      final sourceData = sData.data();
      await destRoomLoc.update({'numRoommates': FieldValue.increment(1)});
      await destLoc.doc(email).set(sourceData!);
      await sourceRoomRef.update({'numRoommates': FieldValue.increment(-1)});
      sourceRef.delete();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$destRoomName is filled with its capacity')));
      return false;
    }
    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
    return false;
  }
}

Future<bool> swapRoom(
    String email,
    String hostelName,
    String roomName,
    String destRoommateEmail,
    String destHostelName,
    String destRoomName,
    BuildContext context) async {
  try {
    final storage = FirebaseFirestore.instance;

    final swapResult = await storage.runTransaction((transaction) async {
      final sourceLoc = storage
          .collection('hostels')
          .doc(hostelName)
          .collection('Rooms')
          .doc(roomName)
          .collection('Roommates');
      final sourceRef = sourceLoc.doc(email);
      final sData = await transaction.get(sourceRef);

      final destLoc = storage
          .collection('hostels')
          .doc(destHostelName)
          .collection('Rooms')
          .doc(destRoomName)
          .collection('Roommates');
      final destRef = destLoc.doc(destRoommateEmail);
      final dData = await transaction.get(destRef);

      final sourceData = sData.data();
      final destData = dData.data();

      transaction.delete(destRef);
      transaction.delete(sourceRef);
      transaction.set(destLoc.doc(email), sourceData!);
      transaction.set(sourceLoc.doc(destRoommateEmail), destData!);

      return true;
    });

    if (swapResult == true) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
    return false;
  }
}

Future<List<DropdownMenuItem>> fetchRoomNames(String hostelName,
    {String? roomname, Source? src}) async {
  List<DropdownMenuItem> list = [];
  final storage = FirebaseFirestore.instance;
  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .get(src == null ? null : GetOptions(source: src));
  storageRef.docs.forEach((element) {
    if (roomname == null || element.id != roomname) {
      list.add(DropdownMenuItem(
        child: Text(element.id),
        value: element.id,
      ));
    }
  });
  return list;
}

Future<List<DropdownMenuItem>> fetchRoommateNames(
    String hostelName, String roomName,
    {Source? src}) async {
  List<DropdownMenuItem> list = [];
  final storage = FirebaseFirestore.instance;
  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommates')
      .get(src == null ? null : GetOptions(source: src));
  storageRef.docs.forEach((element) {
    list.add(DropdownMenuItem(
      child: Text(element['name']),
      value: element.id,
    ));
  });
  return list;
}
