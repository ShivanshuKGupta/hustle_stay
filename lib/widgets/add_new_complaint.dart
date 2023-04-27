import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/hostel.dart';
import '../models/user.dart';

class NewComplaint extends StatefulWidget {
  const NewComplaint({super.key});

  @override
  State<NewComplaint> createState() => _NewComplaintState();
}

void _addComplaint(String title, String body, String location) {
  print("Title: $title");
  print("Body: $body");
  print("Location: $location");
  postComplaint(Complaint(
      location: location,
      cType: ComplaintType.other,
      heading: title,
      posterID: currentUser.rollNo!,
      body: body));
}

class _NewComplaintState extends State<NewComplaint> {
  String? dropdownValue;

  final _titleController = TextEditingController();

  final _bodyController = TextEditingController();
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
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                  onSubmitted: (_) {},
                ),

                // TextField(
                //   decoration: InputDecoration(labelText: 'Title'),
                //   controller: _titleController,
                //   onSubmitted: (_) {},
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text('Location',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground)),
                    SizedBox(width: 20),
                    DropdownButton(
                      value: dropdownValue,
                      items: [
                        for (int i = 0; i < allHostels.length; ++i)
                          DropdownMenuItem(
                            value: allHostels[i].name,
                            child: Text(allHostels[i].name),
                          ),
                        // DropdownMenuItem(
                        //     value: 'Tunga', child: Text('Tungabhadra')),
                        // DropdownMenuItem(value: 'Krishna', child: Text('Krishna')),
                        // DropdownMenuItem(value: 'Acad', child: Text('Acad Block')),
                      ],
                      onChanged: (str) {
                        setState(() {
                          dropdownValue = str;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(width: 20),
                TextField(
                  decoration: InputDecoration(labelText: 'Body'),
                  controller: _bodyController,
                  onSubmitted: (_) {},
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      _addComplaint(_titleController.text, _bodyController.text,
                          dropdownValue!);
                    },
                    child: Text('Submit'),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.purple,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        // Theme.of(context).textTheme.button.color,
                        Colors.white,
                      ),
                    ),
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
