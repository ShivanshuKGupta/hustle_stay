class ReadOnly {
  bool isAdmin = false;
  String type = "student";
  String? name;
  String? hostelName;
  String? roomName;

  void load(Map<String, dynamic> data) {
    isAdmin = data['isAdmin'] ?? false;
    type = data['type'] ?? "student";
    hostelName = data['hostelName'];
    roomName = data['roomName'];
    name = data['name'];
  }

  Map<String, dynamic> encode() {
    return {
      "isAdmin": isAdmin,
      "type": type,
      "name": name,
      if (type == 'student') "hostelName": hostelName,
      if (type == 'student') "roomName": roomName,
    };
  }
}
