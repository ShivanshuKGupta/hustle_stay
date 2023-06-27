import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustle_stay/main.dart';

class ReadOnly {
  bool isAdmin = false;
  String type = "student";

  void load(Map<String, dynamic> data) {
    isAdmin = data['isAdmin'] ?? false;
    type = data['type'] ?? "student";
  }

  Map<String, dynamic> encode() {
    return {
      "isAdmin": isAdmin,
      "type": type,
    };
  }
}

class UserData {
  String? email, name, phoneNumber, address, roomName, hostelName;
  String? imgUrl;
  ReadOnly readonly = ReadOnly();
  UserData({
    this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.imgUrl,
    this.hostelName,
    this.roomName,
  });

  Map<String, dynamic> encode() {
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "address": address,
      "imgUrl": imgUrl,
      "hostelName": hostelName,
      "roomName": roomName,
    };
  }

  void load(Map<String, dynamic> userData) {
    name = userData['name'];
    phoneNumber = userData['phoneNumber'];
    address = userData['address'];
    imgUrl = userData['imgUrl'];
    roomName = userData['roomName'];
    hostelName = userData['hostelName'];
  }
}

Future<UserData> fetchUserData(
  String email, {
  Source? src = Source.cache,
  bool keepUptoDate = false,
}) async {
  UserData userData = UserData();
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    response =
        await firestore.collection('users').doc("$email/editable/details").get(
              src == null ? null : GetOptions(source: src),
            );
    if (keepUptoDate) {
      firestore.collection('users').doc("$email/editable/details").get();
    }
  } catch (e) {
    if (src == Source.cache) {
      response = await firestore
          .collection('users')
          .doc("$email/editable/details")
          .get();
    }
  }
  userData.email = email;
  userData.load(response?.data() ?? {});
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
