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
  int modifiedAt = 0;

  /// Editable
  String? phoneNumber, address;
  String? imgUrl;
  MedicalInfo medicalInfo = MedicalInfo();

  UserData.other({
    this.email,
    String? name,
    this.phoneNumber,
    this.address,
    this.imgUrl,
    required this.medicalInfo,
  });

  UserData({
    this.email,
    String? name,
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

// Future<Map<String, String>> fetchHostelAndRoom(String email) async {
//   final ref =
//       await FirebaseFirestore.instance.collection('users').doc(email).get();
//   Map<String, String> data = {
//     'hostelName': ref.data()!['hostelName'],
//     'roomName': ref.data()!['roomName']
//   };
//   return data;
// }

// Future<bool> modifyPermissions(Map<String, dynamic> data, String email) async {
//   try {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(email)
//         .set({'permissions': data}, SetOptions(merge: true));
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

Future<UserData> fetchUserData(
  String email, {
  Source? src,
}) async {
  UserData userData = UserData(email: email);
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    response = await firestore.collection('users').doc(email).get(
          src == null ? null : GetOptions(source: src),
        );
  } catch (e) {
    if (src == Source.cache) {
      response = await firestore.collection('users').doc(email).get();
    } else {
      rethrow;
    }
  }
  userData.load(response.data() ?? {});
  return userData;
}

/// this fetches all properties
Future<List<UserData>> fetchUsers({List<String>? emails, Source? src}) async {
  final response = await firestore
      .collection('users')
      .get(src == null ? null : GetOptions(source: src));
  return response.docs
      .map((doc) => UserData(email: doc.id)..load(doc.data()))
      .toList();
  // if (emails != null) {
  //   return [for (final email in emails) await fetchUserData(email, src: src)];
  // }
  // return [
  //   for (final doc in (await firestore.collection('users').get(
  //             src == null ? null : GetOptions(source: src),
  //           ))
  //       .docs)
  //     await fetchUserData(doc.id, src: src)
  // ];
}

/// This only fetches readonly properties
Future<List<UserData>> fetchComplainees({Source? src}) async {
  final querySnapshot =
      await firestore.collection('users').where('type', whereIn: [
    'attender',
    'warden',
    'other',
    'club',
  ]).get(src == null ? null : GetOptions(source: src));
  return querySnapshot.docs
      .map((e) => UserData(email: e.id)..load(e.data()))
      .toList();
}

Future<void> updateUserData(UserData userData) async {
  firestore.collection('users').doc(userData.email).set(
        userData.encode(),
      );
  // if account doesn't exists create one
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
  final Source? src;
  final Widget? loadingWidget;
  UserBuilder({
    super.key,
    required this.email,
    required this.builder,
    this.loadingWidget,
    this.src,
  });

  UserData userData = UserData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserData(email, src: src),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          userData = UserData(email: email, name: email);
          if (src == Source.cache) {
            return loadingWidget ?? builder(ctx, userData);
          }
          return FutureBuilder(
            future: fetchUserData(email, src: Source.cache),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                // Returning this Widget when nothing has arrived
                return loadingWidget ?? builder(ctx, userData);
              }
              // Returning this widget from cache while data arrives from server
              userData = snapshot.data!;
              return builder(ctx, userData);
            },
          );
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
  final Future<List<UserData>> Function({Source? src})? provider;
  final Source? src;
  final Widget? loadingWidget;
  const UsersBuilder({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.src,
    this.provider,
    this.emails,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: provider != null
          ? provider!(src: src)
          : fetchUsers(emails: emails, src: src),
      builder: (ctx, snapshot) {
        if (snapshot.hasError && src == Source.cache) {
          return UsersBuilder(builder: builder, loadingWidget: loadingWidget);
        }
        if (!snapshot.hasData) {
          if (src == Source.cache) {
            return loadingWidget ?? circularProgressIndicator();
          }
          return FutureBuilder(
            future: provider != null
                ? provider!(src: Source.cache)
                : fetchUsers(emails: emails, src: Source.cache),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                // Returning this Widget when nothing has arrived
                return loadingWidget ?? circularProgressIndicator();
              }
              // Returning this widget from cache while data arrives from server
              return builder(ctx, snapshot.data!);
            },
          );
        }
        // Returning this widget when data arrives from server
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
        .get();
  } else if (userType == 'admin') {
    userRef = await FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .get();
  } else {
    userRef = await FirebaseFirestore.instance
        .collection('users')
        .where('type', whereIn: ['other', 'club']).get();
  }

  /// No need of this now ----------------------------------
  // final List<Future<DocumentSnapshot<Map<String, dynamic>>>> userDataFutures =
  //     userRef.docs
  //         .map((x) => x.reference.collection('editable').doc('details').get())
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
          .get();

  return querySnapshot.docs
      .map((doc) => UserData(email: doc.id)..load(doc.data()))
      .toList();
  // final List<UserData> list = [];

  // // Perform parallel requests using Future.wait to reduce latency
  // await Future.wait(
  //   querySnapshot.docs.map(
  //     (x) async {
  //       final userDataSnapshot =
  //           await x.reference.collection('editable').doc('details').get();
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
