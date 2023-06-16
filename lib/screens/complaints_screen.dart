import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

import '../widgets/complaints/complaints_list.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ComplaintList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showDialog(
          //     context: context,
          //     builder: (ctx) {
          //       return AlertDialog(
          //         title: const Text('File a Complaint'),
          //         content: SingleChildScrollView(
          //             child: Padding(
          //           padding: EdgeInsets.only(
          //             top: 15.0,
          //             left: 15,
          //             right: 15,
          //             bottom: MediaQuery.of(context).viewInsets.bottom + 15,
          //           ),
          //           child: ComplaintForm(onSubmit: addComplaint),
          //         )),
          //         contentPadding: EdgeInsets.zero,
          //       );
          //     });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => Scaffold(
                appBar: AppBar(
                  title: const Text('File a Complaint'),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ComplaintForm(
                      onSubmit: addComplaint,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
