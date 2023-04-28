import 'package:flutter/material.dart';
import 'package:hustle_stay/models/hostel.dart';
import 'package:hustle_stay/tools/tools.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
