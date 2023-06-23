import 'package:cloud_firestore/cloud_firestore.dart';

enum Role {
  student,
  admin,
  warden,
  attender,
}

class UserData {
  String? email, name, phoneNumber, address;
  Role? role;
  UserData({this.email, this.name, this.phoneNumber, this.address});

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
  final response =
      await store.collection('users').doc("$email/editable/details").get(
            src == null ? null : GetOptions(source: src),
          );
  // if (!response.exists) {
  //   throw Exception("User details not found");
  // }
  userData.load(response.data() ?? {});
  userData.email = email;
  return userData;
}

Future<void> updateUserData(UserData userData) async {
  final store = FirebaseFirestore.instance;
  await store
      .collection('users')
      .doc("${userData.email}/editable/details")
      .set(userData.encode());
}

Map<String, UserData> userInfo = {};

Future<UserData> getUserInfo(String email) async {
  if (userInfo.containsKey(email)) {
    return userInfo[email]!;
  } else {
    UserData user = await fetchUserData(email);
    userInfo[email] = user;
    return user;
  }
}
