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
    return json.encode({
      "canTakeAttendance": canTakeAttendance,
      "canModifyUsers": canModifyUsers,
      "canRegisterComplaint": canRegisterComplaint,
      "canModifyComplaints": canModifyComplaints,
    });
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
