import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoommateData {
  String email;
  bool? onLeave;
  DateTime? leaveStartDate;
  DateTime? leaveEndDate;
  RoommateData(
      {required this.email,
      this.leaveStartDate,
      this.leaveEndDate,
      this.onLeave});
}

class AttendanceRecord {
  bool isPresent;
  String date;
  AttendanceRecord({required this.isPresent, required this.date});
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

final storage = FirebaseFirestore.instance;

Future<List<Room>> fetchRooms(String hostelName, {Source? src}) async {
  final roomsCollectionRef =
      storage.collection('hostels').doc(hostelName).collection('Rooms');

  final roomSnapshot = await roomsCollectionRef
      .get(src != null ? GetOptions(source: src) : null);
  final roomDocs = roomSnapshot.docs;

  final List<Future<List<QueryDocumentSnapshot>>> roommatesDataFutures = [];

  for (final roomDoc in roomDocs) {
    final roomRef = roomDoc.reference;
    final roommatesCollectionRef = roomRef.collection('Roommates');
    final roommatesDataFuture = roommatesCollectionRef
        .get(src != null ? GetOptions(source: src) : null)
        .then((roommatesSnapshot) => roommatesSnapshot.docs);
    roommatesDataFutures.add(roommatesDataFuture);
  }

  final roommatesDataSnapshots = await Future.wait(roommatesDataFutures);

  final List<Room> roomDataList = [];

  for (int i = 0; i < roomDocs.length; i++) {
    final roomDoc = roomDocs[i];
    final roommatesDocs = roommatesDataSnapshots[i];

    final List<RoommateData> roommatesData = roommatesDocs.map((roommateDoc) {
      final data =
          roommateDoc.data() as Map<String, dynamic>; // Explicit type casting
      final onLeave = data['onLeave'] ?? false;
      final leaveStartDate = data['leaveStartDate'] as Timestamp?;
      final leaveEndDate = data['leaveEndDate'] as Timestamp?;

      return RoommateData(
        email: data['email'] ?? '',
        onLeave: onLeave,
        leaveStartDate: leaveStartDate?.toDate(),
        leaveEndDate: leaveEndDate?.toDate(),
      );
    }).toList();

    final roomData = Room(
      capacity: roomDoc['capacity'],
      numberOfRoommates: roomDoc['numRoommates'],
      roomName: roomDoc['roomName'],
      roomMatesData: roommatesData,
    );
    roomDataList.add(roomData);
  }

  return roomDataList;
}

Future<bool> isRoomExists(String hostelName, String roomName) async {
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

Future<void> copyRoommateAttendance(String email, String hostelName,
    String roomName, String destHostelName, String destRoomName) async {
  // print('hi');
  try {
    final collectionRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName)
        .collection('Roommates')
        .doc(email);

    final destRef = storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Rooms')
        .doc(destRoomName)
        .collection('Roommates')
        .doc(email);
    final attendanceRef = collectionRef.collection('Attendance');

    final attendanceSnapshot = await attendanceRef.get();
    final attendanceDocuments = attendanceSnapshot.docs;
    if (attendanceDocuments.isNotEmpty) {
      final batch = storage.batch();
      for (final doc in attendanceDocuments) {
        batch.set(destRef.collection('Attendance').doc(doc.id), doc.data(),
            SetOptions(merge: true));
      }
      await batch.commit();

      final deleteBatch = storage.batch();
      for (final doc in attendanceDocuments) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
    }

    return;
  } catch (e) {
    print(e);
  }
  return;
}

Future<bool> changeRoom(String email, String hostelName, String roomName,
    String destHostelName, String destRoomName, BuildContext context) async {
  try {
    final sourceRoomRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName);
    final sourceRef = sourceRoomRef.collection('Roommates').doc(email);
    final sData = await sourceRef.get();
    final destRoomLoc = storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Rooms')
        .doc(destRoomName);
    final destRoomSnapshot = await destRoomLoc.get();
    final capacity = destRoomSnapshot['capacity'];
    final numRoommates = destRoomSnapshot['numRoommates'];

    if (capacity > numRoommates) {
      final destLoc = destRoomLoc.collection('Roommates');
      final sourceData = sData.data();

      await storage.runTransaction((transaction) async {
        transaction
            .update(destRoomLoc, {'numRoommates': FieldValue.increment(1)});
        transaction.set(destLoc.doc(email), sourceData!);
        transaction
            .update(sourceRoomRef, {'numRoommates': FieldValue.increment(-1)});
      });

      await copyRoommateAttendance(
          email, hostelName, roomName, destHostelName, destRoomName);

      await storage.collection('users').doc(email).set(
          {'hostelName': destHostelName, 'roomName': destRoomName},
          SetOptions(merge: true)).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error occurred in updation')));
      });

      await sourceRef.delete();

      return true;
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$destRoomName is filled with its capacity')));
      return false;
    }
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
    await storage.runTransaction((transaction) async {
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
      print('data getting printed');
      print('sourceData: $sourceData');
      print('destData: $destData');

      transaction.set(destLoc.doc(email), sourceData!, SetOptions(merge: true));
      transaction.set(
          sourceLoc.doc(destRoommateEmail), destData!, SetOptions(merge: true));

      print('here');
      await copyRoommateAttendance(
          email, hostelName, roomName, destHostelName, destRoomName);
      await copyRoommateAttendance(destRoommateEmail, destHostelName,
          destRoomName, hostelName, roomName);

      transaction.set(
          storage.collection('users').doc(email),
          {'hostelName': destHostelName, 'roomName': destRoomName},
          SetOptions(merge: true));
      transaction.set(
          storage.collection('users').doc(destRoommateEmail),
          {'hostelName': hostelName, 'roomName': roomName},
          SetOptions(merge: true));

      transaction.delete(sourceRef);
      transaction.delete(destRef);
    });

    return true;
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

  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .get(src == null ? null : GetOptions(source: src));
  storageRef.docs.forEach((element) {
    if (roomname == null || element.id != roomname) {
      list.add(DropdownMenuItem(
        value: element.id,
        child: Text(
          element.id,
          style: const TextStyle(fontSize: 10),
        ),
      ));
    }
  });
  return list;
}

Future<List<DropdownMenuItem>> fetchRoommateNames(
    String hostelName, String roomName,
    {Source? src}) async {
  List<DropdownMenuItem> list = [];

  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .collection('Roommates')
      .get(src == null ? null : GetOptions(source: src));
  storageRef.docs.forEach((element) {
    list.add(DropdownMenuItem(
      child: Text(
        element['email'],
        style: TextStyle(fontSize: 10),
      ),
      value: element.id,
    ));
  });
  return list;
}

Future<List<AttendanceRecord>> fetchAttendanceByStudent(String email) async {
  List<AttendanceRecord> list = [];

  final infoRef = await storage.collection('users').doc(email).get();
  if (infoRef.exists) {
    final hostelName = infoRef.data()!['hostelName'];
    final roomName = infoRef.data()!['roomName'];
    if (hostelName != null && roomName != null) {
      final attendanceDataRef = await storage
          .collection('hostels')
          .doc(hostelName)
          .collection('Rooms')
          .doc(roomName)
          .collection('Roommates')
          .doc(email)
          .collection('Attendance')
          .get();
      final attendanceData = attendanceDataRef.docs;
      for (final doc in attendanceData) {
        list.add(
            AttendanceRecord(isPresent: doc.data()['isPresent'], date: doc.id));
      }
    }
  }
  return list;
}

Future<bool> deleteRoommate(String email,
    {String? hostelName, String? roomName}) async {
  final user = storage.collection('users').doc(email);
  if (hostelName == null || roomName == null) {
    await user.get().then(
      (value) {
        hostelName = value.data()!['hostelName'];
        roomName = value.data()!['roomName'];
      },
    );
  }
  try {
    final collectionRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName)
        .collection('Roommates')
        .doc(email);

    final attendanceRef = collectionRef.collection('Attendance');
    final batch = storage.batch();
    final attendanceSnapshot = await attendanceRef.get();
    final attendanceDocuments = attendanceSnapshot.docs;
    if (attendanceDocuments.isNotEmpty) {
      batch.update(user, {'hostelName': null, 'roomName': null});
      for (final doc in attendanceDocuments) {
        batch.delete(doc.reference);
      }
    }
    batch.update(
        storage
            .collection('hostels')
            .doc(hostelName)
            .collection('Rooms')
            .doc(roomName),
        {'numRoommates': FieldValue.increment(-1)});
    batch.delete(collectionRef);

    await batch.commit();
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}
