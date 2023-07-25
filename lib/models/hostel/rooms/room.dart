import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:intl/intl.dart';

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

Future<List<Room>> fetchRooms(String hostelName, {Source? src}) async {
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
      .doc('hostelMates')
      .collection('Roommates')
      .where('hostelName', isEqualTo: hostelName)
      .where('roomName', isEqualTo: roomName)
      .get(source == null ? null : GetOptions(source: source));

  for (final x in roommateSnapshot.docs) {
    final data = x.data();
    final internship = data['onInternship'] ?? false;
    final leaveStartDate = data['leaveStartDate'] as Timestamp?;
    final leaveEndDate = data['leaveEndDate'] as Timestamp?;
    list.add(RoommateData(
      email: data['email'] ?? '',
      leaveStartDate: leaveStartDate?.toDate(),
      leaveEndDate: leaveEndDate?.toDate(),
      internship: internship,
    ));
  }
  return list;
}

Future<void> copyRoommateData(String email, String hostelName,
    String? destHostelName, String? destRoomName,
    {Source? source}) async {
  try {
    final collectionRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Roommates')
        .doc(email);

    final destRef = storage
        .collection('hostels')
        .doc('hostelMates')
        .collection('Roommates')
        .doc(email);

    final attendanceRef = collectionRef.collection('Attendance');
    final leaveRef = collectionRef.collection('Leaves');

    final attendanceSnapshot = await attendanceRef
        .get(source == null ? null : GetOptions(source: source));
    final leaveSnapshot =
        await leaveRef.get(source == null ? null : GetOptions(source: source));

    final attendanceDocuments = attendanceSnapshot.docs;
    final leaveDocuments = leaveSnapshot.docs;

    final batch = storage.batch();

    for (final doc in attendanceDocuments) {
      batch.set(
        destRef.collection('Attendance').doc(doc.id),
        doc.data(),
        SetOptions(merge: true),
      );
    }

    for (final doc in leaveDocuments) {
      batch.set(
        destRef.collection('Leaves').doc(doc.id),
        doc.data(),
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    final deleteBatch = storage.batch();

    for (final doc in attendanceDocuments) {
      deleteBatch.delete(doc.reference);
    }

    for (final doc in leaveDocuments) {
      deleteBatch.delete(doc.reference);
    }

    await deleteBatch.commit();

    return;
  } catch (e) {
    return;
  }
}

Future<bool> changeRoom(
  String email,
  String hostelName,
  String roomName,
  String destHostelName,
  String destRoomName,
) async {
  try {
    print('hi');
    final sourceRoomRef = storage
        .collection('hostels')
        .doc(hostelName)
        .collection('Rooms')
        .doc(roomName);
    final sourceRef = storage
        .collection('hostels')
        .doc('hostelMates')
        .collection('Roommates')
        .doc(email);

    final destRoomLoc = storage
        .collection('hostels')
        .doc(destHostelName)
        .collection('Rooms')
        .doc(destRoomName);
    final destRoomSnapshot = await destRoomLoc.get();
    final capacity = destRoomSnapshot['capacity'];
    final numRoommates = destRoomSnapshot['numRoommates'];
    print(capacity);
    print(numRoommates);

    try {
      if (capacity > numRoommates) {
        print('entered');
        final batch = storage.batch();
        batch.set(sourceRoomRef, {'numRoommates': FieldValue.increment(-1)},
            SetOptions(merge: true));
        batch.set(destRoomLoc, {'numRoommates': FieldValue.increment(1)},
            SetOptions(merge: true));
        batch.set(
            sourceRef,
            {'roomName': destRoomName, 'hostelName': destHostelName},
            SetOptions(merge: true));
        batch.set(
            storage.collection('users').doc(email),
            {'roomName': destRoomName, 'hostelName': destHostelName},
            SetOptions(merge: true));
        await batch.commit();
        return true;
      } else {
        print('entered here');
        return false;
      }
    } catch (e) {
      return false;
    }
  } catch (e) {
    // ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(e.toString())));
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
) async {
  try {
    await storage.runTransaction((transaction) async {
      final sourceLoc = storage
          .collection('hostels')
          .doc('hostelMates')
          .collection('Roommates');

      final destRef = sourceLoc.doc(destRoommateEmail);
      final sourceRef = sourceLoc.doc(email);
      try {
        final batch = storage.batch();
        batch.set(destRef, {'roomName': roomName, 'hostelName': hostelName},
            SetOptions(merge: true));
        batch.set(
            sourceRef,
            {'roomName': destRoomName, 'hostelName': destHostelName},
            SetOptions(merge: true));
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
    });
    return true;
  } catch (e) {
    // ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(e.toString())));
    return false;
  }
}

Future<List<String>> fetchRoomNames(String hostelName,
    {String? roomname, Source? src}) async {
  List<String> list = [];

  final storageRef = await storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .get(src == null ? null : GetOptions(source: src));
  for (var element in storageRef.docs) {
    if (roomname == null || element.id != roomname) {
      list.add(element.id);
    }
  }
  return list;
}

Future<List<String>> fetchRoommateNames(String hostelName, String roomName,
    {Source? src}) async {
  List<String> list = [];

  final storageRef = await storage
      .collection('hostels')
      .doc('hostelMates')
      .collection('Roommates')
      .where('hostelName', isEqualTo: hostelName)
      .where('roomName', isEqualTo: roomName)
      .get(src == null ? null : GetOptions(source: src));
  for (var element in storageRef.docs) {
    list.add(element.id);
  }
  return list;
}

Future<bool> deleteRoommate(String email, String hostelName, String? roomName,
    {Source? source}) async {
  final user = storage.collection('users').doc(email);

  try {
    final collectionRef = storage
        .collection('hostels')
        .doc('hostelMates')
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
    String hostelName, String text, bool isEmail,
    {Source? src}) async {
  List<Map<String, String>> list = [];
  final textVal = capitalizeEachWord(text.toLowerCase());

  if (isEmail) {
    QuerySnapshot<Map<String, dynamic>> snapshot = await storage
        .collection('users')
        .where('hostelName', isEqualTo: hostelName)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: text)
        .limit(10)
        .get(src == null ? null : GetOptions(source: src));

    List<Future<void>> snapshotFutures = snapshot.docs.map((element) async {
      list.add({
        'name': element.data()['name'],
        'email': element.id,
        'leading': element.id,
      });
    }).toList();

    await Future.wait(snapshotFutures);
  } else {
    QuerySnapshot<Map<String, dynamic>> snapshot = await storage
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: textVal)
        .limit(10)
        .get(src == null ? null : GetOptions(source: src));

    List<Future<void>> snapshotFutures = snapshot.docs.map((element) async {
      if (hostelName == element.data()['hostelName']) {
        if (textVal == element.data()['name']) {
          list = [
            {
              'name': element.data()['name'],
              'email': element.id,
              'leading': element.data()['name'],
            }
          ];
          return list;
        }
        list.add({
          'name': element.data()['name'],
          'email': element.id,
          'leading': element.data()['name'],
        });
      }
    }).toList();

    await Future.wait(snapshotFutures);
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

Future<RoommateData?> fetchRoommateData(String email,
    {String? hostelName}) async {
  if (hostelName == null) {
    final ref = await storage.collection('users').doc(email).get();
    if (ref.exists) {
      hostelName = ref.data()!['hostelName'];
    } else {
      return null;
    }
  }
  final ref = await storage
      .collection('hostels')
      .doc('hostelMates')
      .collection('Roommates')
      .doc(email)
      .get();
  return ref.exists
      ? RoommateData(
          email: email,
          internship: ref.data()!['onInternship'],
          leaveEndDate: ref.data()!['leaveEndDate'],
          leaveStartDate: ref.data()!['leaveStartDate'],
        )
      : null;
}

Future<bool> addRommates(
    List<String> emails, String hostelName, String roomName) async {
  final batch = storage.batch();
  final userRef = storage.collection('users');
  final ref = storage
      .collection('hostels')
      .doc(hostelName)
      .collection('Rooms')
      .doc(roomName);
  final roommateRef =
      storage.collection('hostels').doc('hostelMates').collection('Roommates');
  final countCheck = await ref.get();
  if (countCheck.data()!['numRoommates'] + emails.length >
      countCheck.data()!['capacity']) {
    return false;
  }
  batch.set(ref, {'numRoommates': FieldValue.increment(emails.length)},
      SetOptions(merge: true));
  for (final x in emails) {
    batch.set(userRef.doc(x), {'hostelName': hostelName, 'roomName': roomName},
        SetOptions(merge: true));
    batch.set(roommateRef.doc(x),
        {'email': x, 'roomName': roomName, 'hostelName': hostelName});
  }
  await batch.commit();
  return true;
}

Future<Map<String, dynamic>?> getUserAttendanceRecord(String email,
    {bool isCurrentUser = false, String? hostelName}) async {
  Map<String, dynamic> list = {};
  if (!isCurrentUser) {
    if (currentUser.readonly.hostelName != null) {
      hostelName = currentUser.readonly.hostelName;
    } else {
      return null;
    }
  } else if (hostelName == null) {
    final ref = await storage.collection('users').doc(email).get();
    if (ref.exists) {
      hostelName = ref.data()!['hostelName'];
      if (hostelName == null) {
        return null;
      }
    } else {
      return null;
    }
  }
  final attendanceStat = await getAttendanceStatistics(email, hostelName!);
  list['statistics'] = attendanceStat;
  // var dataRef = await storage
  //     .collection('hostels')
  //     .doc(hostelName)
  //     .collection('Roommates')
  //     .doc(email)
  //     .get();
  // String status = 'noData';
  // if (dataRef.exists) {
  //   final dData = dataRef.data()!['leaveEndDate'];
  //   if (dData != null && (DateTime.now().isBefore(dData.toDate()))) {
  //     status = dataRef.data()!['onInternship'] ? 'onInternship' : 'onLeave';
  //   } else {
  //     dataRef = await dataRef.reference
  //         .collection('Attendance')
  //         .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
  //         .get();
  //   }
  // }
  // list['todayStatus'] = dataRef.exists ? dataRef.data()!['status'] : status;

  return list;
}

Future<void> copyAllToHostelmates() async {
  final ref = await storage.collection('hostels').get();
  ref.docs.forEach((element) async {
    final dataRef = await element.reference.collection('Roommates').get();
    dataRef.docs.forEach((elementVal) async {
      final sourceData = elementVal.data();
      await storage.runTransaction((transaction) async {
        transaction.set(
            storage
                .collection('hostels')
                .doc('hostelMates')
                .collection('Roommates')
                .doc(elementVal.id),
            sourceData);

        await copyRoommateData(elementVal.id, element.id, null, null);
        transaction.delete(elementVal.reference);
        return true;
      });
    });
  });
}
