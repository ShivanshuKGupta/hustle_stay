import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';

class EditComplaintsPage extends StatelessWidget {
  final String? id;
  const EditComplaintsPage({
    super.key,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'File a Complaint' : "Edit Complaint"),
        actions: [
          if (id != null)
            IconButton(
                onPressed: () async {
                  final response = await askUser(
                    context,
                    'Do you really wish to delete this complaint?',
                    yes: true,
                    no: true,
                  );
                  if (response == 'yes') {
                    await deleteComplaint(id: id);
                    Navigator.of(context).pop("deleted");
                  }
                },
                icon: const Icon(Icons.delete_rounded))
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
