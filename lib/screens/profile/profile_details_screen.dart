import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/auth/edit_profile_screen.dart';
import 'package:hustle_stay/screens/profile/profile_preview.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/settings/section.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final UserData user;
  const ProfileDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (user.email == currentUser.email ||
              currentUser.readonly.permissions.users.update == true)
            IconButton(
              onPressed: () {
                navigatorPush(context, EditProfile(user: user));
              },
              icon: const Icon(
                Icons.edit_rounded,
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ProfilePreview(
              user: user,
              showDetailsPage: false,
            ),
            const Divider(),
            Section(
              title: 'Personal Information',
              children: [
                if (user.phoneNumber != null)
                  KeyValueRow(
                    attribute: 'Phone Number',
                    value: user.phoneNumber!,
                  ),
                if (user.address != null)
                  KeyValueRow(
                    attribute: 'Address',
                    value: user.address!,
                  ),
              ],
            ),
            Section(
              title: 'Hostel Information',
              children: [
                if (user.readonly.hostelName != null)
                  KeyValueRow(
                    attribute: 'Hostel',
                    value: user.readonly.hostelName!,
                  ),
                if (user.readonly.roomName != null)
                  KeyValueRow(
                    attribute: 'Room',
                    value: user.readonly.roomName!,
                  ),
              ],
            ),
            Section(
              title: 'Medical Information',
              children: [
                if (user.medicalInfo.bloodGroup != null)
                  KeyValueRow(
                    attribute: 'Blood Group',
                    value:
                        "${user.medicalInfo.bloodGroup!.name}${user.medicalInfo.rhBloodType!.index == 0 ? '+' : '-'}",
                  ),
                if (user.medicalInfo.dob != null)
                  KeyValueRow(
                    attribute: 'Date of Birth',
                    value: ddmmyyyy(user.medicalInfo.dob!),
                  ),
                if (user.medicalInfo.phoneNumber != null)
                  KeyValueRow(
                    attribute: 'Emergency Phone Number',
                    value: user.medicalInfo.phoneNumber!,
                  ),
                if (user.medicalInfo.height != null)
                  KeyValueRow(
                    attribute: 'Height',
                    value: user.medicalInfo.height!.toString(),
                  ),
                if (user.medicalInfo.weight != null)
                  KeyValueRow(
                    attribute: 'Weight',
                    value: user.medicalInfo.weight!.toString(),
                  ),
                if (user.medicalInfo.sex != null)
                  KeyValueRow(
                    attribute: 'Sex',
                    value: user.medicalInfo.sex!.name.toPascalCase(),
                  ),
                if (user.medicalInfo.organDonor != null)
                  KeyValueRow(
                    attribute: 'Organ Donor?',
                    value: user.medicalInfo.organDonor! ? 'Yes' : 'No',
                  ),
                if (user.medicalInfo.allergies != null)
                  KeyValueRow(
                    attribute: 'Allergies',
                    value: user.medicalInfo.allergies!.toString(),
                  ),
                if (user.medicalInfo.medicalConditions != null)
                  KeyValueRow(
                    attribute: 'Medical Conditions',
                    value: user.medicalInfo.medicalConditions!.toString(),
                  ),
                if (user.medicalInfo.medications != null)
                  KeyValueRow(
                    attribute: 'Medications',
                    value: user.medicalInfo.medications!.toString(),
                  ),
                if (user.medicalInfo.remarks != null)
                  KeyValueRow(
                    attribute: 'Remarks',
                    value: user.medicalInfo.remarks!.toString(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.attribute,
    required this.value,
    this.width,
  });

  final String attribute;
  final double? width;
  final String value;

  @override
  Widget build(BuildContext context) {
    double w = width ?? MediaQuery.of(context).size.width;
    return SizedBox(
      width: w,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(attribute),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
