import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/medical_info.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/loading_builder.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';
import 'package:hustle_stay/widgets/other/select_many.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  Set<String> bloodGroups = {}, rhBloodTypes = {};
  DateTimeRange? dobRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Medical Info'),
      ),
      body: CacheBuilder(
        loadingWidget: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circularProgressIndicator(),
              const Text('Fetching medical data of all users'),
            ],
          ),
        ),
        src: Source.cache,
        builder: (ctx, users) {
          return RefreshIndicator(
            onRefresh: () async {
              // await fetchUsers();
              setState(() {});
            },
            child: Column(
              children: [
                SelectMany(
                  title: 'Blood Groups?',
                  subtitle: 'Select Blood Groups to Filter',
                  allOptions: BloodGroup.values.map((e) => e.name).toSet(),
                  selectedOptions: bloodGroups,
                  onChange: (bloodGroups) {
                    setState(() {
                      this.bloodGroups = bloodGroups;
                    });
                  },
                ),
                SelectMany(
                  allOptions: RhBloodType.values.map((e) => e.name).toSet(),
                  selectedOptions: rhBloodTypes,
                  onChange: (rhBloodTypes) {
                    setState(() {
                      this.rhBloodTypes = rhBloodTypes;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingElevatedButton(
                      icon: const Icon(Icons.date_range_rounded),
                      label: Text(dobRange == null
                          ? 'Choose DOB Range'
                          : '${ddmmyyyy(dobRange!.start)} - ${ddmmyyyy(dobRange!.end)}'),
                      onPressed: () async {
                        DateTimeRange? dateTimeRange =
                            await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.utc(1969),
                          lastDate: DateTime.now(),
                          initialDateRange: dobRange,
                        );
                        if (dateTimeRange != null) {
                          setState(() {
                            dobRange = dateTimeRange;
                          });
                        }
                      },
                    ),
                    if (dobRange != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            dobRange = null;
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
                const Divider(),
                LoadingBuilder(
                  builder: (ctx, progress) async {
                    final filteredUsers = users.where(
                      (user) {
                        if (bloodGroups.isEmpty &&
                            rhBloodTypes.isEmpty &&
                            dobRange == null) {
                          return true;
                        }
                        return (bloodGroups.isEmpty ||
                                (user.medicalInfo.bloodGroup != null &&
                                    bloodGroups.contains(
                                        user.medicalInfo.bloodGroup!.name))) &&
                            (rhBloodTypes.isEmpty ||
                                (user.medicalInfo.rhBloodType != null &&
                                    rhBloodTypes.contains(
                                        user.medicalInfo.rhBloodType!.name))) &&
                            (dobRange == null ||
                                (user.medicalInfo.dob != null &&
                                    dobRange!.start
                                            .compareTo(user.medicalInfo.dob!) >=
                                        0 &&
                                    dobRange!.end
                                            .compareTo(user.medicalInfo.dob!) <=
                                        0));
                      },
                    ).toList();
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (ctx, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            onTap: () {
                              showUserPreview(context, user);
                            },
                            title: Text(user.name ?? user.email!),
                            subtitle: Wrap(
                              children: [
                                if (user.medicalInfo.bloodGroup != null)
                                  Text(
                                    user.medicalInfo.bloodGroup!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                if (user.medicalInfo.rhBloodType != null)
                                  Text(
                                    user.medicalInfo.rhBloodType!.index == 0
                                        ? '+'
                                        : '-',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                if (user.medicalInfo.dob != null)
                                  Text(
                                    ddmmyyyy(user.medicalInfo.dob!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                              ],
                            ),
                          );
                        },
                        itemCount: filteredUsers.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        provider: fetchUsers,
      ),
    );
  }
}
