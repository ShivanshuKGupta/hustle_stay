import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustle_stay/main.dart';

class ReadOnly {
  bool isAdmin = false;
  String type = "student";
  String? hostelName;
  String? roomName;
  void load(Map<String, dynamic> data) {
    isAdmin = data['isAdmin'] ?? false;
    type = data['type'] ?? "student";
    hostelName = data['hostelName'];
    roomName = data['roomName'];
  }

  Map<String, dynamic> encode() {
    return {
      "isAdmin": isAdmin,
      "type": type,
    };
  }
}

class UserData {
  String? email, name, phoneNumber, address;
  String? imgUrl;
  ReadOnly readonly = ReadOnly();
  UserData({
    this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.imgUrl,
  });

  Map<String, dynamic> encode() {
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "address": address,
      "imgUrl": imgUrl,
    };
  }

  void load(Map<String, dynamic> userData) {
    name = userData['name'];
    phoneNumber = userData['phoneNumber'];
    address = userData['address'];
    imgUrl = userData['imgUrl'];
  }
}

Future<UserData> fetchUserData(
  String email, {
  Source? src,
  bool keepUptoDate = false,
}) async {
  UserData userData = UserData();
  DocumentSnapshot<Map<String, dynamic>>? response;

  /// Loading editable properties ...
  try {
    /// Trying with given config
    response =
        await firestore.collection('users').doc("$email/editable/details").get(
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
  return userData;
}

Future<List<UserData>> fetchUsers(List<String> emails, {Source? src}) async {
  return [for (final email in emails) await fetchUserData(email, src: src)];
}

Future<List<String>> fetchComplainees() async {
  final querySnapshot =
      await firestore.collection('users').where('type', whereIn: [
    'attender',
    'warden',
  ]).get();
  return querySnapshot.docs.map((e) => e.id).toList();
}

Future<void> updateUserData(UserData userData) async {
  await firestore.runTransaction((transaction) async {
    // Updating Editable details
    await firestore
        .collection('users')
        .doc("${userData.email}/editable/details")
        .set(userData.encode());
    // Updating readonly details
    if (currentUser.readonly.isAdmin) {
      await firestore
          .collection('users')
          .doc(userData.email)
          .set(userData.readonly.encode());
    }
    // if account doesn't exists create one
    try {
      await auth.createUserWithEmailAndPassword(
        email: userData.email!,
        password: "123456",
        // TODO: change the above pwd to a radomized pwd
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        rethrow;
      }
    }
  });
}

/// This function is responsible for logging user in
Future<void> login(String email, String password) async {
  UserCredential userCredential;
  userCredential =
      await auth.signInWithEmailAndPassword(email: email, password: password);
  currentUser = await fetchUserData(userCredential.user!.email!);
}

var currentUser = UserData();
