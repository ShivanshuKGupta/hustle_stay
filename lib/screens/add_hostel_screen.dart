import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddHostel extends StatefulWidget {
  AddHostel({super.key});

  @override
  State<AddHostel> createState() => _AddHostelState();
}

class _AddHostelState extends State<AddHostel> {
  final _formKey = GlobalKey<FormState>();

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
                      if (value == null) return "Hostel name is required";

                      return null;
                    },
                    onSaved: (value) {},
                  ),
                  TextFormField(
                    maxLength: 30,
                    decoration: const InputDecoration(
                      label: Text("Hostel Description"),
                    ),
                    validator: (value) {
                      if (value == null) return "Empty Description";
                      return null;
                    },
                    onSaved: (value) {},
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
                        onPressed: () {},
                        icon: const Icon(Icons.save_rounded),
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
              )),
        ),
      ),
    );
  }
}
