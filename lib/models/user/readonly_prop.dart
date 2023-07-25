import 'package:hustle_stay/models/user/permissions.dart';

class ReadOnly {
  bool isAdmin = false;
  String type = "student";
  String? name;
  String? hostelName;
  String? roomName;
  Permissions permissions = Permissions();

  void load(Map<String, dynamic> data) {
    isAdmin = data['isAdmin'] ?? false;
    type = data['type'] ?? "student";
    hostelName = data['hostelName'];
    roomName = data['roomName'];
    name = data['name'];
    permissions.load(
      ((data['permissions'] ?? <String, dynamic>{}) as Map<String, dynamic>)
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

  Map<String, dynamic> encode() {
    return {
      "isAdmin": isAdmin,
      "type": type,
      "name": name,
      "permissions": permissions.encode(),
      if (type == 'student') "hostelName": hostelName,
      if (type == 'student') "roomName": roomName,
    };
  }
}
