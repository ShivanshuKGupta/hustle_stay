import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hustle_stay/models/hostel.dart';
import 'package:hustle_stay/tools/tools.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/room.dart';

class AddHostel extends StatefulWidget {
  AddHostel({super.key});

  @override
  State<AddHostel> createState() => _AddHostelState();
}

class _AddHostelState extends State<AddHostel> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String name = "", description = "";

  void _reset() {
    _formKey.currentState!.reset();
  }

  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _addHostel() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await uploadHostel(Hostel(
        name: name,
        description: description,
      ));
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Hostel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                    label: Text("Hostel Name"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Hostel name is required";
                    return null;
                  },
                  onSaved: (value) {
                    name = value!;
                  },
                ),
                TextFormField(
                  maxLength: 30,
                  decoration: const InputDecoration(
                    label: Text("Hostel Description"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Empty Description";
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                if (_image != null)
                  Image.file(File(_image!.path))
                else
                  Text('No image selected.'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select an Image'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addHostel,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Add'),
                    ),
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.delete),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// List<TextEditingController> _roomIDs = [];

// class _RoomAdder extends StatefulWidget {
//   const _RoomAdder({super.key});

//   @override
//   State<_RoomAdder> createState() => _RoomAdderState();
// }

// class _RoomAdderState extends State<_RoomAdder> {
//   TextEditingController _lengthTxtField = TextEditingController();
//   int length = 0;
//   @override
//   Widget build(BuildContext context) {
//     final deviceSize = MediaQuery.of(context).size;
//     return Card(
//       color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Flexible(
//                   flex: 3,
//                   child: TextField(
//                     keyboardType: TextInputType.number,
//                     controller: _lengthTxtField,
//                     decoration: const InputDecoration(
//                       label: Text("Total Rooms"),
//                     ),
//                   ),
//                 ),
//                 Flexible(
//                   flex: 1,
//                   child: TextButton(
//                       onPressed: () {
//                         final value = _lengthTxtField.text;
//                         if (value.isEmpty) return;
//                         int newLen = 0;
//                         try {
//                           newLen = int.parse(value);
//                         } catch (e) {
//                           return;
//                         }
//                         if (newLen >= 1) {
//                           setState(() {
//                             length = newLen;
//                             _roomIDs = [
//                               for (int i = 0; i < length; ++i)
//                                 TextEditingController()
//                             ];
//                           });
//                         }
//                       },
//                       child: const Text('List Rooms')),
//                 )
//               ],
//             ),
//             for (int i = 0; i < length; ++i)
//               ListTile(
//                 title: TextField(
//                   controller: _roomIDs[i],
//                   decoration: const InputDecoration(
//                     label: Text("Room ID"),
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }
