import 'dart:convert';

class Permissions {
  bool canTakeAttendance,
      canModifyUsers,
      canRegisterComplaint,
      canModifyComplaints;
  Permissions({
    this.canTakeAttendance = false,
    this.canModifyUsers = false,
    this.canRegisterComplaint = false,
    this.canModifyComplaints = false,
  });
  String encode() {
    String str =
        "${canTakeAttendance ? "0" : "1"}${canModifyUsers ? "0" : "1"}${canRegisterComplaint ? "0" : "1"}${canModifyComplaints ? "0" : "1"}";
    return json.encode(str);
  }

  void decode(String str) {
    String str =
        "${canTakeAttendance ? "0" : "1"}${canModifyUsers ? "0" : "1"}${canRegisterComplaint ? "0" : "1"}${canModifyComplaints ? "0" : "1"}";
  }
}

Permissions? decodeAsPermissions(String response) {
  if (response == 'null') return null;
  Map<String, dynamic> details = json.decode(response);
  details = details.values.firstWhere((element) => true);
  return Permissions(
    canTakeAttendance: details['canTakeAttendance'],
    canModifyUsers: details['canModifyUsers'],
    canRegisterComplaint: details['canRegisterComplaint'],
    canModifyComplaints: details['canModifyComplaints'],
  );
}
