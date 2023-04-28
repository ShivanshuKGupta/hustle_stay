import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/hostel.dart';
import '../models/user.dart';

class NewComplaint extends StatefulWidget {
  const NewComplaint({super.key});

  @override
  State<NewComplaint> createState() => _NewComplaintState();
}

class _NewComplaintState extends State<NewComplaint> {
  String? dropdownValue;

  void _addComplaint(String title, String body, String location) async {
    setState(() {
      _isLoading = true;
    });
    await postComplaint(Complaint(
      location: location,
      cType: ComplaintType.other,
      heading: title,
      posterID: currentUser.rollNo!,
      body: body,
      entryTime: DateTime.now(),
    ));
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  final _titleController = TextEditingController();

  final _bodyController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewPadding.bottom),
      child: SingleChildScrollView(
        child: Card(
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                  onSubmitted: (_) {},
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text('Location',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground)),
                    const SizedBox(width: 20),
                    DropdownButton(
                      value: dropdownValue,
                      items: [
                        for (int i = 0; i < allHostels.length; ++i)
                          DropdownMenuItem(
                            value: allHostels[i].name,
                            child: Text(allHostels[i].name),
                          ),
                      ],
                      onChanged: (str) {
                        setState(() {
                          dropdownValue = str;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                TextField(
                  decoration: const InputDecoration(labelText: 'Body'),
                  controller: _bodyController,
                  onSubmitted: (_) {},
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _addComplaint(_titleController.text,
                                _bodyController.text, dropdownValue!);
                          },
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(10)),
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.purple,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        Colors.white,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
