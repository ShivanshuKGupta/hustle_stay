import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/image.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/profile_image.dart';

class EditProfile extends StatefulWidget {
  EditProfile({super.key, UserData? user}) {
    this.user = user ?? UserData();
  }

  late final UserData user;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  File? img;

  Future<void> save(context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      widget.user.imgUrl = img != null
          ? await uploadImage(
              context, img, widget.user.email!, "profile-image.jpg")
          : widget.user.imgUrl;
      await updateUserData(widget.user);
      Navigator.of(context).pop(true); // to show that a change was done
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ProfileImage(
                  url: widget.user.imgUrl,
                  onChanged: (value) {
                    img = value;
                  },
                ),
                Text(
                  widget.user.email ?? "",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Divider(),
                _section(
                  'Personal Information',
                  [
                    if (widget.user.email == null)
                      TextFormField(
                        key: UniqueKey(),
                        maxLength: 50,
                        enabled: widget.user.email == null,
                        decoration: const InputDecoration(
                          label: Text("Email"),
                        ),
                        initialValue: widget.user.name,
                        validator: (email) {
                          return Validate.email(email);
                        },
                        onSaved: (email) {
                          widget.user.email = email!.trim();
                        },
                      ),
                    TextFormField(
                      key: UniqueKey(),
                      maxLength: 50,
                      decoration: const InputDecoration(
                        label: Text("Name"),
                      ),
                      initialValue: widget.user.name,
                      validator: (name) {
                        return Validate.name(name);
                      },
                      onSaved: (value) {
                        widget.user.name = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        label: Text("Phone Number"),
                      ),
                      initialValue: widget.user.phoneNumber,
                      validator: (name) {
                        return Validate.phone(name, required: false);
                      },
                      onSaved: (value) {
                        widget.user.phoneNumber = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      maxLength: 200,
                      keyboardType: TextInputType.streetAddress,
                      decoration: const InputDecoration(
                        label: Text("Address"),
                      ),
                      initialValue: widget.user.address,
                      validator: (name) {
                        return Validate.text(name, required: false);
                      },
                      onSaved: (value) {
                        widget.user.address = value!.trim();
                      },
                    ),
                    if (currentUser.readonly.isAdmin)
                      DropdownButtonFormField(
                          key: UniqueKey(),
                          decoration:
                              const InputDecoration(label: Text('Type')),
                          value: widget.user.readonly.type,
                          items:
                              ['attender', 'warden', 'student', 'other', "club"]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            widget.user.readonly.type = value ?? "student";
                          }),
                    if (widget.user.email != currentUser.email &&
                        currentUser.readonly.isAdmin)
                      DropdownButtonFormField(
                          key: UniqueKey(),
                          decoration:
                              const InputDecoration(label: Text('Admin')),
                          value: widget.user.readonly.isAdmin,
                          items: [true, false]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            widget.user.readonly.isAdmin = value ?? false;
                          }),
                  ],
                ),
                _section(
                  'Medical Information',
                  [
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        label: Text("Emergency Phone Number"),
                      ),
                      initialValue: widget.user.medicalInfo.phoneNumber,
                      validator: (name) {
                        return Validate.phone(name, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.phoneNumber = value!.trim();
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            key: UniqueKey(),
                            decoration: const InputDecoration(
                                label: Text('Blood Group')),
                            value: widget.user.medicalInfo.bloodGroup,
                            items: BloodGroup.values
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              widget.user.medicalInfo.bloodGroup = value;
                            },
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField(
                            key: UniqueKey(),
                            decoration: const InputDecoration(
                              label: Text('RH Blood Type'),
                            ),
                            value: widget.user.medicalInfo.rhBloodType,
                            items: RhBloodType.values
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              widget.user.medicalInfo.rhBloodType = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Height"),
                      ),
                      initialValue: widget.user.medicalInfo.height == null
                          ? null
                          : widget.user.medicalInfo.height!.toString(),
                      validator: (name) {
                        return Validate.integer(name, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.height =
                            int.tryParse(value!.trim());
                      },
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Weight"),
                      ),
                      initialValue: widget.user.medicalInfo.weight == null
                          ? null
                          : widget.user.medicalInfo.weight!.toString(),
                      validator: (name) {
                        return Validate.integer(name, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.weight =
                            int.tryParse(value!.trim());
                      },
                    ),
                    DropdownButtonFormField(
                      key: UniqueKey(),
                      decoration: const InputDecoration(
                        label: Text('Sex'),
                      ),
                      value: widget.user.medicalInfo.sex,
                      items: Sex.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        widget.user.medicalInfo.sex = value;
                      },
                    ),
                    DropdownButtonFormField(
                      key: UniqueKey(),
                      decoration:
                          const InputDecoration(label: Text('Organ Donor?')),
                      value: widget.user.medicalInfo.organDonor,
                      items: [true, false]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e ? "Yes" : "No"),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        widget.user.medicalInfo.organDonor = value ?? false;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date of Birth'),
                        ElevatedButton.icon(
                          label: Text(widget.user.medicalInfo.dob != null
                              ? ddmmyyyy(widget.user.medicalInfo.dob!)
                              : "Click to choose"),
                          onPressed: () async {
                            final chosenDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.utc(1900),
                              lastDate: DateTime.now(),
                            );
                            setState(() {
                              widget.user.medicalInfo.dob =
                                  chosenDate ?? widget.user.medicalInfo.dob;
                            });
                          },
                          icon: const Icon(Icons.date_range_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
                _section(
                  'Health Information',
                  [
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        label: Text("Allergies"),
                      ),
                      initialValue: widget.user.medicalInfo.allergies,
                      validator: (value) {
                        return Validate.text(value, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.allergies = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        label: Text("Medical Conditions"),
                      ),
                      initialValue: widget.user.medicalInfo.medicalConditions,
                      validator: (value) {
                        return Validate.text(value, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.medicalConditions =
                            value!.trim();
                      },
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        label: Text("Medications"),
                      ),
                      initialValue: widget.user.medicalInfo.medications,
                      validator: (value) {
                        return Validate.text(value, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.medications = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: UniqueKey(),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        label: Text("Remarks"),
                      ),
                      initialValue: widget.user.medicalInfo.remarks,
                      validator: (value) {
                        return Validate.text(value, required: false);
                      },
                      onSaved: (value) {
                        widget.user.medicalInfo.remarks = value!.trim();
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () {
                              save(context);
                            },
                      icon: _loading
                          ? circularProgressIndicator()
                          : Icon(
                              widget.user.email == null
                                  ? Icons.person_add_rounded
                                  : Icons.save_rounded,
                            ),
                      label: Text(widget.user.email == null ? 'Add' : 'Save'),
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
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
