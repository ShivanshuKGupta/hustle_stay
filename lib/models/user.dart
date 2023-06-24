import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Source? src = Source.cache,
  bool keepUptoDate = false,
}) async {
  final store = FirebaseFirestore.instance;
  UserData userData = UserData();
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    response =
        await store.collection('users').doc("$email/editable/details").get(
              src == null ? null : GetOptions(source: src),
            );
    if (keepUptoDate) {
      store.collection('users').doc("$email/editable/details").get();
    }
  } catch (e) {
    if (src == Source.cache) {
      response =
          await store.collection('users').doc("$email/editable/details").get();
    }
  }
  userData.email = email;
  userData.load(response?.data() ?? {});
  try {
    response = await store.collection('users').doc(email).get(
          src == null ? null : GetOptions(source: src),
        );
    if (keepUptoDate) {
      store.collection('users').doc(email).get();
    }
  } catch (e) {
    if (src == Source.cache) {
      response = await store.collection('users').doc(email).get();
    }
  }
  userData.readonly.load(response?.data() ?? {});
  return userData;
}

Future<void> updateUserData(UserData userData) async {
  final store = FirebaseFirestore.instance;

  await store.runTransaction((transaction) async {
    // Updating Editable details
    await store
        .collection('users')
        .doc("${userData.email}/editable/details")
        .set(userData.encode());
    // Updating readonly details
    if (currentUser.readonly.isAdmin) {
      await store
          .collection('users')
          .doc(userData.email)
          .set(userData.readonly.encode());
    }
    // if account doesn't exists create one
    final auth = FirebaseAuth.instance;
    try {
      await auth.createUserWithEmailAndPassword(
        email: userData.email!,
        password: "123456",
        // TODO: change the above pwd to a radomized pwd
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        throw e;
      }
    }
  });
}

var currentUser = UserData();
