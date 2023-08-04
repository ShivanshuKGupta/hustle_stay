import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/medical_info.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/tools.dart';
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
      body: UsersBuilder(
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
              await fetchUsers();
              setState(() {});
            },
            child: ListView(
              children: [
                SelectMany(
                  title: 'Blood Groups?',
                  subtitle: 'Select Blood Groups to Filter',
                  allOptions: BloodGroup.values.map((e) => e.name).toSet(),
                  selectedOptions: bloodGroups,
                  onChange: (bloodGroups) {
                    this.bloodGroups = bloodGroups;
                  },
                ),
                SelectMany(
                  allOptions: RhBloodType.values.map((e) => e.name).toSet(),
                  selectedOptions: rhBloodTypes,
                  onChange: (rhBloodTypes) {
                    this.rhBloodTypes = rhBloodTypes;
                  },
                ),
                const SizedBox(height: 10),
                LoadingElevatedButton(
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(dobRange == null
                      ? 'Choose DOB Range'
                      : '${ddmmyyyy(dobRange!.start)} - ${ddmmyyyy(dobRange!.end)}'),
                  onPressed: () async {
                    DateTimeRange? dateTimeRange = await showDateRangePicker(
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
                const Divider(),
                // ListView.builder(itemBuilder: itemBuilder)
                // add a widget which show a loading widget when loading or else will show a widget retured by a builder
                // it should also show the loading progress
              ],
            ),
          );
        },
        provider: fetchUsers,
      ),
    );
  }
}
