import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

class AddComplaintsPage extends StatelessWidget {
  const AddComplaintsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
