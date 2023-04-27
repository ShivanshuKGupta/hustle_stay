enum complaintType {
  Water,
  Electricity,
  Cleaning,
  Maintenance,
  Emergency,
}

class Complaint {
  complaintType cType;
  String heading;
  String body;
  String location;

  Complaint(
      {required this.location,
      required this.cType,
      required this.heading,
      required this.body});
}
