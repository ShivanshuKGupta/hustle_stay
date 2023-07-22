import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

class EditComplaintsPage extends StatelessWidget {
  final ComplaintData? complaint;
  final Future<void> Function()? deleteMe;
  final Category? category;
  const EditComplaintsPage({
    super.key,
    this.complaint,
    this.deleteMe,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(complaint == null ? 'File a Complaint' : "Edit Complaint"),
        actions: [
          if (complaint != null && deleteMe != null)
            IconButton(
              onPressed: deleteMe,
              icon: const Icon(Icons.delete_rounded),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ComplaintForm(
            category: category,
            complaint: complaint,
          ),
        ),
      ),
    );
  }
}
