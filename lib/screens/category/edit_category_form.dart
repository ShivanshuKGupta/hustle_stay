import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/providers/image.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/multi_choser.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';
import 'package:hustle_stay/widgets/profile_image.dart';

// ignore: must_be_immutable
class EditCategoryForm extends StatefulWidget {
  Category category;
  final List<String> allRecepients;
  EditCategoryForm(
      {super.key, required this.category, required this.allRecepients});

  @override
  State<EditCategoryForm> createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends State<EditCategoryForm> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? enteredID;
  File? img;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return; // if not validated, return
    if (widget.category.defaultReceipient.isEmpty) {
      showMsg(context, "A default receipient is required.");
      return;
    }
    _formKey.currentState!.save(); // Saving
    setState(() {
      _loading = true;
    });
    try {
      widget.category.id = enteredID ?? widget.category.id;
      widget.category.logoUrl = img != null
          ? await uploadImage(context, img, "categories", widget.category.id)
          : widget.category.logoUrl;
      await updateCategory(widget.category);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      return;
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfileImage(
                url: widget.category.logoUrl,
                onChanged: (value) {
                  img = value;
                },
              ),
              if (widget.category.id.isEmpty)
                TextFormField(
                  key: UniqueKey(),
                  maxLength: 50,
                  enabled: widget.category.id.isEmpty,
                  decoration: const InputDecoration(
                    label: Text("Category Name/ID"),
                  ),
                  initialValue: enteredID,
                  validator: (id) {
                    return Validate.text(id, required: true);
                  },
                  onChanged: (id) {
                    enteredID = id.trim();
                  },
                  onSaved: (id) {
                    enteredID = id!.trim();
                  },
                ),
              MultiChooser(
                hintTxt: "Select a receipient",
                allOptions: widget.allRecepients,
                chosenOptions: widget.category.allReceipients,
                onUpdate: (value) {
                  setState(() {
                    widget.category.allReceipients = value;
                  });
                },
                label: 'All Receipients',
              ),
              MultiChooser(
                hintTxt: "Select a receipient",
                key: UniqueKey(),
                allOptions: widget.category.allReceipients,
                chosenOptions: widget.category.defaultReceipient,
                onUpdate: (value) {
                  widget.category.defaultReceipient = value;
                },
                label: 'Default Receipients',
              ),
              TextFormField(
                key: UniqueKey(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("Default Priority"),
                ),
                initialValue: widget.category.defaultPriority.toString(),
                validator: (value) {
                  return Validate.integer(value, required: true);
                },
                onSaved: (value) {
                  widget.category.defaultPriority = int.parse(value!.trim());
                },
              ),
              // TODO: Add a cooldown field for category
              ElevatedButton.icon(
                onPressed: () async {
                  final chosenColor = await showColorPicker(
                    context,
                    widget.category.color,
                  );
                  setState(() {
                    widget.category.color = chosenColor;
                  });
                },
                icon: Icon(
                  Icons.color_lens_rounded,
                  color: widget.category.color,
                ),
                label: const Text("Pick a color"),
              ),
              const SizedBox(height: 10),
              CategoriesBuilder(
                builder: (ctx, categories) {
                  allParents.addAll(categories.map((e) => e.parent));
                  return SelectOne(
                    title: 'Select a Parent Category',
                    subtitle: 'This will be used for grouping categories',
                    allOptions: allParents.map((e) => e).toSet()
                      ..add('+ Create New'),
                    selectedOption: widget.category.parent,
                    onChange: (value) {
                      if (value == '+ Create New') {
                        promptUser(context, question: 'New Parent Category')
                            .then((value) {
                          if (value != null) {
                            setState(() => allParents.add(value));
                          }
                        });
                        return false;
                      }
                      widget.category.parent = value;
                      return true;
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _save,
                    icon: _loading
                        ? circularProgressIndicator()
                        : const Icon(Icons.save_rounded),
                    label: const Text('Save'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
