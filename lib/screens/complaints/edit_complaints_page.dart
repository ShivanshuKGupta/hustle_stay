import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

class EditComplaintsPage extends StatelessWidget {
  final String? id;
  final Future<void> Function()? deleteMe;
  const EditComplaintsPage({
    super.key,
    this.id,
    this.deleteMe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'File a Complaint' : "Edit Complaint"),
        actions: [
          if (id != null && deleteMe != null)
            IconButton(
                onPressed: deleteMe, icon: const Icon(Icons.delete_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ComplaintForm(
            id: id,
            onSubmit: (complaint) async {
              await updateComplaint(complaint);
            },
          ),
        ),
      ),
    );
  }
}
