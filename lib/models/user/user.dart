import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/medical_info.dart';
import 'package:hustle_stay/models/user/readonly_prop.dart';
import 'package:hustle_stay/tools.dart';

class UserData {
  String? email, phoneNumber, address;
  String? get name {
    return readonly.name;
  }

  set name(String? newName) {
    readonly.name = newName;
  }

  String? imgUrl;
  ReadOnly readonly = ReadOnly();
  late MedicalInfo medicalInfo;
  UserData.other(
      {this.email,
      String? name,
      this.phoneNumber,
      this.address,
      this.imgUrl,
      required this.medicalInfo,
      required this.readonly}) {
    readonly.name = name;
  }

  UserData({
    this.email,
    String? name,
    this.phoneNumber,
    this.address,
    this.imgUrl,
  }) {
    medicalInfo = MedicalInfo();
    readonly.name = name;
  }

  Map<String, dynamic> encode() {
    return {
      "phoneNumber": phoneNumber,
      "address": address,
      "imgUrl": imgUrl,
      "medicalInfo": medicalInfo.encode(),
    };
  }

  void load(Map<String, dynamic> userData) {
    phoneNumber = userData['phoneNumber'];
    address = userData['address'];
    imgUrl = userData['imgUrl'];
    medicalInfo.load(userData['medicalInfo'] ?? {});
  }
}

Future<Map<String, String>> fetchHostelAndRoom(String email) async {
  final ref =
      await FirebaseFirestore.instance.collection('users').doc(email).get();
  Map<String, String> data = {
    'hostelName': ref.data()!['hostelName'],
    'roomName': ref.data()!['roomName']
  };
  return data;
}

Future<bool> modifyPermissions(Map<String, dynamic> data, String email) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .set({'permissions': data}, SetOptions(merge: true));
    return true;
  } catch (e) {
    return false;
  }
}

Future<UserData> fetchUserData(
  String email, {
  Source? src,
  bool keepUptoDate = false,
  bool readonly = false,
}) async {
  UserData userData = UserData();
  DocumentSnapshot<Map<String, dynamic>>? response;
  userData.email = email;

  /// Loading readonly properties ...
  try {
    response = await firestore.collection('users').doc(email).get(
          src == null ? null : GetOptions(source: src),
        );
    if (keepUptoDate) {
      firestore.collection('users').doc(email).get();
    }
  } catch (e) {
    if (src == Source.cache) {
      response = await firestore.collection('users').doc(email).get();
    }
  }
  userData.readonly.load(response?.data() ?? {});

// Some correction
  // firestore.collection('users').doc(email).set(userData.readonly.encode());

  if (!readonly) {
    /// Loading editable properties ...
    try {
      /// Trying with given config
      response = await firestore
          .collection('users')
          .doc("$email/editable/details")
          .get(
            src == null ? null : GetOptions(source: src),
          );
      if (keepUptoDate) {
        firestore.collection('users').doc("$email/editable/details").get();
      }
    } catch (e) {
      /// If failed then use default configuration
      if (src == Source.cache) {
        response = await firestore
            .collection('users')
            .doc("$email/editable/details")
            .get();
      }
    }
    userData.email = email;
    userData.load(response?.data() ?? {});
  }
  return userData;
}

/// this fetches all properties
Future<List<UserData>> fetchUsers({List<String>? emails, Source? src}) async {
  if (emails != null) {
    return [for (final email in emails) await fetchUserData(email, src: src)];
  }
  return [
    for (final doc in (await firestore.collection('users').get(
              src == null ? null : GetOptions(source: src),
            ))
        .docs)
      await fetchUserData(doc.id, src: src)
  ];
}

/// This only fetches readonly properties
Future<List<UserData>> fetchAllUserReadonlyProperties({Source? src}) async {
  final docs = (await firestore.collection('users').get(
            src == null ? null : GetOptions(source: src),
          ))
      .docs;
  return docs.map((doc) {
    return UserData(email: doc.id)..readonly.load(doc.data());
  }).toList();
}

/// This only fetches readonly properties
Future<List<UserData>> fetchComplainees({Source? src}) async {
  final querySnapshot =
      await firestore.collection('users').where('type', whereIn: [
    'attender',
    'warden',
  ]).get(src == null ? null : GetOptions(source: src));
  return querySnapshot.docs
      .map((e) => UserData(email: e.id)..readonly.load(e.data()))
      .toList();
}

Future<void> updateUserData(UserData userData) async {
  final batch = firestore.batch();
  // Updating Editable details
  batch.set(
    firestore.collection('users').doc("${userData.email}/editable/details"),
    userData.encode(),
  );
  // Updating readonly details
  if (currentUser.readonly.isAdmin) {
    batch.set(
      firestore.collection('users').doc(userData.email),
      userData.readonly.encode(),
    );
  }
  // commiting
  await batch.commit();
  // if account doesn't exists create one
  try {
    await auth.createUserWithEmailAndPassword(
      email: userData.email!,
      password: "123456",
    );
  } on FirebaseAuthException catch (e) {
    if (e.code != 'email-already-in-use') {
      rethrow;
    }
  }
}

/// This function is responsible for logging user in
Future<void> login(String email, String password) async {
  UserCredential userCredential;
  userCredential =
      await auth.signInWithEmailAndPassword(email: email, password: password);
  // final token = FirebaseMessaging.instance.getToken();
  // await FirebaseFirestore.instance
  //     .collection('userTokens')
  //     .doc(email)
  //     .collection('Tokens')
  //     .doc()
  //     .set({'token': token});

  currentUser = await fetchUserData(userCredential.user!.email!);
}

var currentUser = UserData();

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
          : (emails == null
              ? fetchAllUserReadonlyProperties(src: src)
              : fetchUsers(emails: emails, src: src)),
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
                : (emails == null
                    ? fetchAllUserReadonlyProperties(src: Source.cache)
                    : fetchUsers(emails: emails, src: Source.cache)),
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

Future<List<UserData>> fetchSpecificUsers(String userType) async {
  final List<UserData> list = [];

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

  final List<Future<DocumentSnapshot<Map<String, dynamic>>>> userDataFutures =
      userRef.docs
          .map((x) => x.reference.collection('editable').doc('details').get())
          .toList();

  final userDataSnapshots = await Future.wait(userDataFutures);

  for (int i = 0; i < userDataSnapshots.length; i++) {
    final userData = userDataSnapshots[i];
    if (userData.exists) {
      final readOnly = ReadOnly();
      final medicalInfo = MedicalInfo();

      readOnly.load(userRef.docs[i].data());
      if (userData.data()!['medicalInfo'] != null) {
        medicalInfo.load(userData.data()!['medicalInfo']);
      }
      list.add(
        UserData.other(
          email: userRef.docs[i].id,
          address: userData.data()!['address'],
          imgUrl: userData.data()!['imgUrl'],
          name: userRef.docs[i]['name'],
          medicalInfo: medicalInfo,
          phoneNumber: userData.data()!['phoneNumber'],
          readonly: readOnly,
        ),
      );
    }
  }

  return list;
}

Future<List<UserData>> fetchNoHostelUsers() async {
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('type', isEqualTo: 'student')
      .where('hostelName', isNull: true)
      .get();

  final List<UserData> list = [];

  // Perform parallel requests using Future.wait to reduce latency
  await Future.wait(
    querySnapshot.docs.map(
      (x) async {
        final userDataSnapshot =
            await x.reference.collection('editable').doc('details').get();
        if (userDataSnapshot.exists) {
          list.add(
            UserData(
              email: x.id,
              name: userDataSnapshot.data()!['name'],
              imgUrl: userDataSnapshot.data()!['imgUrl'],
            ),
          );
        }
      },
    ),
  );

  return list;
}
