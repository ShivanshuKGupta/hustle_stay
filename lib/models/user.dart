import 'package:cloud_firestore/cloud_firestore.dart';

enum Role {
  student,
  warden,
  attender,
}

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
  ReadOnly readonly = ReadOnly();
  UserData({
    this.email,
    this.name,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> encode() {
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "address": address,
    };
  }

  void load(Map<String, dynamic> userData) {
    name = userData['name'];
    phoneNumber = userData['phoneNumber'];
    address = userData['address'];
  }
}

var currentUser = UserData();

Future<UserData> fetchUserData(String email, {Source? src}) async {
  final store = FirebaseFirestore.instance;
  UserData userData = UserData();
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    response =
        await store.collection('users').doc("$email/editable/details").get(
              src == null ? null : GetOptions(source: src),
            );
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
  await store
      .collection('users')
      .doc("${userData.email}/editable/details")
      .set(userData.encode());
  if (currentUser.readonly.isAdmin) {
    await store
        .collection('users')
        .doc(userData.email)
        .set(userData.readonly.encode());
  }
}
