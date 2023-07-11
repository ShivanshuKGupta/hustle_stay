import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoommateData {
  String email;
  bool? onLeave;
  DateTime? leaveStartDate;
  DateTime? leaveEndDate;
  bool? internship;
  RoommateData(
      {required this.email,
      this.leaveStartDate,
      this.leaveEndDate,
      this.internship,
      this.onLeave});
}

class UserSearchData {
  final String name;
  final String email;
  UserSearchData({required this.name, required this.email});
}

class Room {
  int numberOfRoommates;
  String roomName;
  int capacity;
  // double? statusFraction;

  Room({
    required this.numberOfRoommates,
    required this.roomName,
    required this.capacity,
  });
}

final storage = FirebaseFirestore.instance;

Future<List<Room>> fetchRooms(String hostelName, DateTime date,
    {Source? src}) async {
  final roomsCollectionRef =
      storage.collection('hostels').doc(hostelName).collection('Rooms');

  final roomSnapshot = await roomsCollectionRef
      .get(src != null ? GetOptions(source: src) : null);
  final roomDocs = roomSnapshot.docs;

  final List<Room> roomDataList = [];

  for (int i = 0; i < roomDocs.length; i++) {
    final roomDoc = roomDocs[i];

    final roomData = Room(
        capacity: roomDoc['capacity'],
        numberOfRoommates: roomDoc['numRoommates'],
        roomName: roomDoc['roomName']);
    roomDataList.add(roomData);
  }

  return roomDataList;
}

// Future<List<Room>> fetchRooms(String hostelName, DateTime date, {Source? src}) async {
//   final roomsCollectionRef = storage.collection('hostels').doc(hostelName).collection('Rooms');

//   final roomSnapshot = await roomsCollectionRef.get(src != null ? GetOptions(source: src) : null);
//   final roomDocs = roomSnapshot.docs;

//   final List<Future<Room>> roomFutures = roomDocs.map((roomDoc) async {
//     double val = 0;
//     if (roomDoc['numRoommates'] > 0) {
//       final ref = await storage.collection('hostels').doc(hostelName).collection('Roommates').where('roomName', isEqualTo: roomDoc.id).get();

//       final attendanceFutures = ref.docs.map((x) async {
//         final attendRef = await x.reference.collection('Attendance').doc(DateFormat('yyyy-MM-dd').format(date)).get();
//         if (attendRef.exists && attendRef.data()!['status'] != 'absent') {
//           return 1;
//         } else {
//           return 0;
//         }
//       });

//       final attendanceResults = await Future.wait(attendanceFutures);
//       final xval = attendanceResults.fold(0, (sum, val) => sum + val);
//       val = xval / roomDoc.data()['numRoommates'];
//     }

//     return Room(
//       capacity: roomDoc['capacity'],
//       numberOfRoommates: roomDoc['numRoommates'],
//       roomName: roomDoc['roomName'],
//       statusFraction: roomDoc['numRoommates'] > 0 ? val : null,
//     );
//   }).toList();

//   final roomDataList = await Future.wait(roomFutures);

//   return roomDataList;
// }

Future<bool> isRoomExists(String hostelName, String roomName,
    {Source? source}) async {
  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName)
      .get(source == null ? null : GetOptions(source: source));
  return storageRef.exists;
}

Future<bool> deleteRoom(String roomName, String hostelName,
    {Source? source}) async {
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

Future<List<RoommateData>> fetchRoommates(String hostelName, String roomName,
    {Source? source}) async {
  List<RoommateData> list = [];
  final roommateSnapshot = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .where('roomName', isEqualTo: roomName)
      .get(source == null ? null : GetOptions(source: source));

  for (final x in roommateSnapshot.docs) {
    final data = x.data();
    final onLeave = data['onLeave'] ?? false;
    final internship = data['onInternship'] ?? false;
    final leaveStartDate = data['leaveStartDate'] as Timestamp?;
    final leaveEndDate = data['leaveEndDate'] as Timestamp?;
    list.add(RoommateData(
      email: data['email'] ?? '',
      onLeave: onLeave,
      leaveStartDate: leaveStartDate?.toDate(),
      leaveEndDate: leaveEndDate?.toDate(),
      internship: internship,
    ));
  }
  return list;
}

Future<void> copyRoommateAttendance(String email, String hostelName,
    String roomName, String destHostelName, String destRoomName,
    {Source? source}) async {
  try {
    final collectionRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Roommates')
        .doc(email);

    final destRef = storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Roommates')
        .doc(email);
    final attendanceRef = collectionRef.collection('Attendance');

    final attendanceSnapshot = await attendanceRef
        .get(source == null ? null : GetOptions(source: source));
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
    return;
  }
}

Future<bool> changeRoom(String email, String hostelName, String roomName,
    String destHostelName, String destRoomName, BuildContext context,
    {Source? source}) async {
  try {
    final sourceRoomRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName);
    final sourceRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Roommates')
        .doc(email);

    final destRoomLoc = storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Rooms')
        .doc(destRoomName);
    final destRoomSnapshot = await destRoomLoc
        .get(source == null ? null : GetOptions(source: source));
    final capacity = destRoomSnapshot['capacity'];
    final numRoommates = destRoomSnapshot['numRoommates'];
    if (destHostelName == hostelName) {
      try {
        if (capacity > numRoommates) {
          final batch = storage.batch();
          batch.set(sourceRoomRef, {'numRoommates': FieldValue.increment(-1)},
              SetOptions(merge: true));
          batch.set(destRoomLoc, {'numRoommates': FieldValue.increment(1)},
              SetOptions(merge: true));
          batch.set(
              sourceRef, {'roomName': destRoomName}, SetOptions(merge: true));
          batch.set(storage.collection('users').doc(email),
              {'roomName': destRoomName}, SetOptions(merge: true));
          await batch.commit();
          return true;
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$destRoomName is filled with its capacity')));
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    final destDataLoc = storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Roommates');

    final roomdata = {'roomName': destRoomName, 'hostelName': destHostelName};
    if (capacity > numRoommates) {
      final sData = await sourceRef
          .get(source == null ? null : GetOptions(source: source));
      final sourceData = sData.data();
      await storage.runTransaction((transaction) async {
        transaction
            .update(destRoomLoc, {'numRoommates': FieldValue.increment(1)});
        transaction.set(destDataLoc.doc(email), sourceData!);
        transaction.set(
            destDataLoc.doc(email), roomdata, SetOptions(merge: true));
        transaction
            .update(sourceRoomRef, {'numRoommates': FieldValue.increment(-1)});
        transaction.set(
            storage.collection('users').doc(email),
            {'roomName': destRoomName, 'hostelName': destHostelName},
            SetOptions(merge: true));
        await copyRoommateAttendance(
            email, hostelName, roomName, destHostelName, destRoomName);
        transaction.delete(sourceRef);

        return true;
      });
      return false;
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
      final sourceLoc =
          storage.collection('hostels').doc(hostelName).collection('Roommates');

      final destLoc = storage
          .collection('hostels')
          .doc(destHostelName)
          .collection('Roommates');
      final destRef = destLoc.doc(destRoommateEmail);
      final sourceRef = sourceLoc.doc(email);
      if (destHostelName == hostelName) {
        try {
          final batch = storage.batch();
          batch.set(destRef, {'roomName': roomName}, SetOptions(merge: true));
          batch.set(
              sourceRef, {'roomName': destRoomName}, SetOptions(merge: true));
          batch.set(
              storage.collection('users').doc(email),
              {'roomName': destRoomName, 'hostelName': destHostelName},
              SetOptions(merge: true));
          batch.set(storage.collection('users').doc(destRoommateEmail),
              {'roomName': roomName}, SetOptions(merge: true));
          await batch.commit();
          return true;
        } catch (e) {
          return false;
        }
      }

      final sData = await transaction.get(sourceRef);

      final dData = await transaction.get(destRef);

      final sourceData = sData.data();
      final destData = dData.data();

      transaction.set(destLoc.doc(email), sourceData!, SetOptions(merge: true));
      transaction.set(
          sourceLoc.doc(destRoommateEmail), destData!, SetOptions(merge: true));

      await copyRoommateAttendance(
          email, hostelName, roomName, destHostelName, destRoomName);
      await copyRoommateAttendance(destRoommateEmail, destHostelName,
          destRoomName, hostelName, roomName);
      transaction.set(
          storage.collection('users').doc(email),
          {'roomName': destRoomName, 'hostelName': destHostelName},
          SetOptions(merge: true));
      transaction.set(
          storage.collection('users').doc(destRoommateEmail),
          {'roomName': roomName, 'hostelName': hostelName},
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
  for (var element in storageRef.docs) {
    if (roomname == null || element.id != roomname) {
      list.add(DropdownMenuItem(
        value: element.id,
        child: Text(
          element.id,
          style: const TextStyle(fontSize: 10),
        ),
      ));
    }
  }
  return list;
}

Future<List<DropdownMenuItem>> fetchRoommateNames(
    String hostelName, String roomName,
    {Source? src}) async {
  List<DropdownMenuItem> list = [];

  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Roommates')
      .where('roomName', isEqualTo: roomName)
      .get(src == null ? null : GetOptions(source: src));
  for (var element in storageRef.docs) {
    list.add(DropdownMenuItem(
      value: element.id,
      child: Text(
        element['email'],
        style: const TextStyle(fontSize: 10),
      ),
    ));
  }
  return list;
}

Future<bool> deleteRoommate(String email, String hostelName, String? roomName,
    {Source? source}) async {
  final user = storage.collection('users').doc(email);

  try {
    final collectionRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Roommates')
        .doc(email);

    final attendanceRef = collectionRef.collection('Attendance');
    final batch = storage.batch();
    final attendanceSnapshot = await attendanceRef
        .get(source == null ? null : GetOptions(source: source));
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
    return false;
  }
}

String capitalizeEachWord(String x) {
  List<String> z = x.split(' ');
  for (int i = 0; i < z.length; i++) {
    z[i] = "${z[i][0].toUpperCase()}${z[i].substring(1)}";
  }
  return z.join(' ');
}

int calculateSimilarity(String a, String b) {
  int matchCount = 0;
  int minLength = a.length < b.length ? a.length : b.length;

  for (int i = 0; i < minLength; i++) {
    if (a[i] == b[i]) {
      matchCount++;
    }
  }

  return matchCount;
}

Future<List<Map<String, String>>> fetchOptions(
    String hostelName, String text, bool isEmail) async {
  List<Map<String, String>> list = [];
  List<String> listData = [];

  if (isEmail) {
    QuerySnapshot<Map<String, dynamic>> snapshot = await storage
        .collection('users')
        .where('hostelName', isEqualTo: hostelName)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: text)
        .limit(20)
        .get();

    List<Future<void>> snapshotFutures = snapshot.docs.map((element) async {
      final nameRef =
          await element.reference.collection('editable').doc('details').get();
      final name = nameRef.data()!['name'];
      list.add({
        'name': name,
        'email': element.id,
        'leading': element.id,
        'imageUrl': nameRef.data()!['imgUrl'],
      });
      listData.add(element.id);
    }).toList();

    await Future.wait(snapshotFutures);
  } else {
    text = capitalizeEachWord(text);
    QuerySnapshot<Map<String, dynamic>> secondSnapshot = await storage
        .collection('users')
        .where('hostelName', isEqualTo: hostelName)
        .get();

    int x = 0;
    List<Future<void>> secondSnapshotFutures =
        secondSnapshot.docs.map((elementVal) async {
      if (x < 20) {
        final elementRef = await elementVal.reference
            .collection('editable')
            .where('name', isGreaterThanOrEqualTo: text)
            .get();
        if (elementRef.size > 0) {
          final element = elementRef.docs.first;

          list.add({
            'name': element.data()['name'],
            'email': elementVal.id,
            'leading': element.data()['name'],
            'imageUrl': element.data()['imgUrl'],
          });
          listData.add(element.id);
          x++;
        }
      }
    }).toList();

    await Future.wait(secondSnapshotFutures);
  }
  if (list.isNotEmpty) {
    list.sort((a, b) {
      int valA = calculateSimilarity(a['leading']!, text);
      int valB = calculateSimilarity(b['leading']!, text);
      return valB.compareTo(valA);
    });
  }

  return list;
}

Future<Room> fetchRoomOptions(String hostelName, String value) async {
  value = capitalizeEachWord(value);
  QuerySnapshot<Map<String, dynamic>> data = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .where(FieldPath.documentId, isEqualTo: value)
      .limit(1)
      .get();
  if (data.size == 0) {
    data = await storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: value)
        .limit(1)
        .get();
  }
  return Room(
      numberOfRoommates: data.docs[0].data()['numRoommates'],
      roomName: data.docs[0].id,
      capacity: data.docs[0].data()['capacity']);
}
