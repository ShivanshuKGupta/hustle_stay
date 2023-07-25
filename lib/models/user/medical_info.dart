enum BloodGroup {
  O,
  A,
  B,
  // ignore: constant_identifier_names
  AB,
}

enum RhBloodType {
  positive,
  negative,
}

enum Sex {
  male,
  female,
}

class MedicalInfo {
  String? phoneNumber; // Emergency Phone Number
  BloodGroup? bloodGroup; // BloodGroup like O,A etc.
  RhBloodType? rhBloodType; // BloodGroup like O,A etc.
  int? height, weight;
  Sex? sex; // Male/Female
  bool? organDonor; // Yes/No
  DateTime? dob; // Date of Birth
  /// Health Conditions
  String? allergies; // Allergies (if any)
  String? medicalConditions; // Medical Conditions (if any)
  String? medications; // Medication (if any)
  String? remarks; // Additional Info
  MedicalInfo({
    this.phoneNumber,
    this.bloodGroup,
    this.dob,
    this.height,
    this.organDonor,
    this.sex,
    this.weight,
    this.rhBloodType,
    this.allergies,
    this.medicalConditions,
    this.medications,
    this.remarks,
  });

  Map<String, dynamic> encode() {
    return {
      "phoneNumber": phoneNumber,
      "allergies": allergies,
      "medicalConditions": medicalConditions,
      "medications": medications,
      "remarks": remarks,
      if (bloodGroup != null) "bloodGroup": bloodGroup!.index,
      if (dob != null) "dob": dob!.millisecondsSinceEpoch.toString(),
      "height": height,
      "organDonor": organDonor,
      if (sex != null) "sex": sex!.index,
      if (rhBloodType != null) "rhBloodType": rhBloodType!.index,
      "weight": weight,
    };
  }

  void load(Map<String, dynamic> data) {
    phoneNumber = data['phoneNumber'];
    allergies = data['allergies'];
    medicalConditions = data['medicalConditions'];
    medications = data['medications'];
    remarks = data['remarks'];
    bloodGroup = data['bloodGroup'] != null
        ? BloodGroup.values[data['bloodGroup']]
        : null;
    dob = data['dob'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            int.parse(data['dob']),
          )
        : null;
    height = data['height'];
    organDonor = data['organDonor'];
    sex = data['sex'] != null ? Sex.values[data['sex']] : null;
    rhBloodType = data['rhBloodType'] != null
        ? RhBloodType.values[data['rhBloodType']]
        : null;
    weight = data['weight'];
  }
}
