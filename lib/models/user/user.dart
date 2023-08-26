import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/medical_info.dart';
import 'package:hustle_stay/models/user/permissions.dart';
import 'package:hustle_stay/screens/profile/profile_preview.dart';
import 'package:hustle_stay/tools.dart';

class UserData {
  /// Readonly
  String? email;
  bool isAdmin = false;
  String type = "student";
  String? name;
  String? hostelName;
  String? roomName;
  Permissions permissions = Permissions();
  String? fcmToken;
  int modifiedAt = 0;

  /// Editable
  String? phoneNumber, address;
  String? imgUrl;
  MedicalInfo medicalInfo = MedicalInfo();

  UserData.other({
    this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.imgUrl,
    required this.medicalInfo,
  });

  UserData({
    this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.imgUrl,
  });

  Map<String, dynamic> encode() {
    return {
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (address != null) "address": address,
      if (imgUrl != null) "imgUrl": imgUrl,
      "medicalInfo": medicalInfo.encode(),
      "isAdmin": isAdmin,
      "modifiedAt": modifiedAt,
      "type": type,
      "fcmToken": fcmToken,
      if (name != null) "name": name,
      "permissions": permissions.encode(),
      if (type == 'student') "hostelName": hostelName,
      if (type == 'student') "roomName": roomName,
    };
  }

  void load(Map<String, dynamic> data) {
    phoneNumber = data['phoneNumber'] ?? phoneNumber;
    address = data['address'] ?? address;
    imgUrl = data['imgUrl'] ?? imgUrl;
    medicalInfo.load(data['medicalInfo'] ?? medicalInfo.encode());
    isAdmin = data['isAdmin'] ?? isAdmin;
    type = data['type'] ?? type;
    hostelName = data['hostelName'] ?? hostelName;
    roomName = data['roomName'] ?? roomName;
    name = data['name'] ?? name;
    fcmToken = data['fcmToken'] ?? fcmToken;
    modifiedAt = data['modifiedAt'] ?? modifiedAt;
    permissions.load(
      ((data['permissions'] ?? permissions.encode()) as Map<String, dynamic>)
          .map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as bool),
          ),
        ),
      ),
    );
  }
}

Future<void> initializeUsers() async {
  const String key = 'usersLastModifiedAt';
  int usersLastModifiedAt = prefs!.getInt(key) ?? -1;
  // if (usersLastModifiedAt == -1) {
  //   try {
  //     usersLastModifiedAt = (await firestore
  //             .collection('users')
  //             .orderBy('modifiedAt', descending: true)
  //             .limit(1)
  //             .get(const GetOptions(source: Source.cache)))
  //         .docs[0]
  //         .data()['modifiedAt'];
  //   } catch (e) {
  //     // if data doesn't exists in cache then do nothing
  //   }
  // }
  final response = await firestore
      .collection('users')
      .where(
        'modifiedAt',
        isGreaterThan: usersLastModifiedAt,
      )
      .get();
  int maxModifiedAt = usersLastModifiedAt;
  for (var doc in response.docs) {
    maxModifiedAt = max(
        maxModifiedAt, (UserData(email: doc.id)..load(doc.data())).modifiedAt);
  }
  prefs!.setInt(key, maxModifiedAt);
}

Future<UserData> fetchUserData(String email,
    {Source? src = Source.cache}) async {
  UserData userData = UserData(email: email);
  DocumentSnapshot<Map<String, dynamic>>? response;
  response = await firestore.collection('users').doc(email).get(
        src == null ? null : GetOptions(source: src),
      );
  userData.load(response.data() ?? {});
  return userData;
}

/// this fetches all properties
Future<List<UserData>> fetchUsers({List<String>? emails}) async {
  if (emails != null) {
    return [for (final email in emails) await fetchUserData(email)];
  }
  final response = await firestore
      .collection('users')
      .get(const GetOptions(source: Source.cache));
  return response.docs
      .map((doc) => UserData(email: doc.id)..load(doc.data()))
      .toList();
  // return [
  //   for (final doc in (await firestore.collection('users').get(
  //             GetOptions(source: Source.cache),
  //           ))
  //       .docs)
  //     await fetchUserData(doc.id, src: src)
  // ];
}

/// This only fetches readonly properties
Future<List<UserData>> fetchComplainees() async {
  final querySnapshot =
      await firestore.collection('users').where('type', whereIn: [
    'attender',
    'warden',
    'other',
    'club',
  ]).get(const GetOptions(source: Source.cache));
  return querySnapshot.docs
      .map((e) => UserData(email: e.id)..load(e.data()))
      .toList();
}

Future<void> updateUserData(UserData userData) async {
  final batch = firestore.batch();
  userData.modifiedAt = DateTime.now().millisecondsSinceEpoch;
  batch.set(
    firestore.collection('users').doc(userData.email),
    userData.encode(),
  );
  // if account doesn't exists create one
  if (currentUser.isAdmin == true) {
    try {
      await auth.createUserWithEmailAndPassword(
        email: userData.email!,
        password: "123456",
      );
      // login(currentUser.email!, '123456');
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        rethrow;
      }
    }
  }
  batch.set(firestore.doc('modifiedAt/users'), {
    "lastModifiedAt": userData.modifiedAt,
  });
  await batch.commit();
}

/// This function is responsible for logging user in
Future<void> login(String email, String password) async {
  await auth.signInWithEmailAndPassword(email: email, password: password);
}

UserData currentUser = UserData();

/// A widget used to display widget using UserData
/// This will change according to the userData
// ignore: must_be_immutable
class UserBuilder extends StatelessWidget {
  final String email;
  final Widget Function(BuildContext ctx, UserData userData) builder;
  final Widget? loadingWidget;
  UserBuilder({
    super.key,
    required this.email,
    required this.builder,
    this.loadingWidget,
  });

  UserData userData = UserData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserData(email),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          userData = UserData(email: email, name: email);
          // Returning this Widget when nothing has arrived
          return loadingWidget ?? builder(ctx, userData);
        }
        // Returning this widget when data arrives from server
        userData = snapshot.data!;
        return builder(ctx, userData);
      },
    );
  }
}

/// A widget used to display widget using UserData
/// This will change according to the userData
// ignore: must_be_immutable
class UsersBuilder extends StatelessWidget {
  final List<String>? emails;
  final Widget Function(BuildContext ctx, List<UserData> users) builder;
  final Future<List<UserData>> Function()? provider;
  final Widget? loadingWidget;
  const UsersBuilder({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.provider,
    this.emails,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: provider != null ? provider!() : fetchUsers(emails: emails),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return loadingWidget ?? circularProgressIndicator();
        }
        return builder(ctx, snapshot.data!);
      },
    );
  }
}

/// TODO: Sani, see the below function it is changed now
Future<List<UserData>> fetchSpecificUsers(String userType) async {
  // final List<UserData> list = [];

  QuerySnapshot<Map<String, dynamic>> userRef;

  if (userType != 'admin' && userType != 'other') {
    userRef = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: userType)
        .get(const GetOptions(source: Source.cache));
  } else if (userType == 'admin') {
    userRef = await FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .get(const GetOptions(source: Source.cache));
  } else {
    userRef = await FirebaseFirestore.instance.collection('users').where('type',
        whereIn: ['other', 'club']).get(const GetOptions(source: Source.cache));
  }

  /// No need of this now ----------------------------------
  // final List<Future<DocumentSnapshot<Map<String, dynamic>>>> userDataFutures =
  //     userRef.docs
  //         .map((x) => x.reference.collection('editable').doc('details').get(const GetOptions(source: Source.cache)))
  //         .toList();

  final List<UserData> users = userRef.docs
      .map((doc) => UserData(email: doc.id)..load(doc.data()))
      .toList();

  return users;
  // final userDataSnapshots = await Future.wait(userDataFutures);

  // for (int i = 0; i < userDataSnapshots.length; i++) {
  //   final userData = userDataSnapshots[i];
  //   if (userData.exists) {
  //     final medicalInfo = MedicalInfo();

  //     load(userRef.docs[i].data());
  //     if (userData.data()!['medicalInfo'] != null) {
  //       medicalInfo.load(userData.data()!['medicalInfo']);
  //     }
  //     list.add(
  //       UserData.other(
  //         email: userRef.docs[i].id,
  //         address: userData.data()!['address'],
  //         imgUrl: userData.data()!['imgUrl'],
  //         name: userRef.docs[i]['name'],
  //         medicalInfo: medicalInfo,
  //         phoneNumber: userData.data()!['phoneNumber'],
  //         readonly: readOnly,
  //       ),
  //     );
  //   }
  // }

  // return list;
}

/// TODO: Sani see this function as well
Future<List<UserData>> fetchNoHostelUsers() async {
  final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'student')
          .where('hostelName', isNull: true)
          .get(const GetOptions(source: Source.cache));

  return querySnapshot.docs
      .map((doc) => UserData(email: doc.id)..load(doc.data()))
      .toList();
  // final List<UserData> list = [];

  // // Perform parallel requests using Future.wait to reduce latency
  // await Future.wait(
  //   querySnapshot.docs.map(
  //     (x) async {
  //       final userDataSnapshot =
  //           await x.reference.collection('editable').doc('details').get(const GetOptions(source: Source.cache));
  //       if (userDataSnapshot.exists) {
  //         list.add(
  //           UserData(
  //             email: x.id,
  //             name: x['name'],
  //             imgUrl: userDataSnapshot.data()!['imgUrl'],
  //           ),
  //         );
  //       }
  //     },
  //   ),
  // );

  // return list;
}

Future showUserPreview(BuildContext context, UserData user) {
  return Navigator.of(context).push(
    DialogRoute(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          top: 40,
          bottom: 20,
          right: 10,
          left: 10,
        ),
        content: ProfilePreview(user: user),
      ),
    ),
  );
}
