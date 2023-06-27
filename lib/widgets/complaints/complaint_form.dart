import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/image.dart';

import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/profile_image.dart';

class ComplaintForm extends StatefulWidget {
  String? id;
  final Future<void> Function(ComplaintData) onSubmit;
  ComplaintForm({super.key, required this.onSubmit, this.id});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formkey = GlobalKey<FormState>();

  bool _loading = false;
  bool _userFetchLoading = false;
  late ComplaintData complaint;

  List<UserData> recepients = [];

  File? img;

  @override
  void initState() {
    super.initState();
    complaint = ComplaintData(
      from: currentUser.email!,
      id: widget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: "",
      to: [],
      resolved: false,
    );
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      _userFetchLoading = true;
    });
    if (widget.id != null) {
      complaint = await fetchComplaint(widget.id!);
    }
    final querySnapshot =
        await firestore.collection('users').where('type', whereIn: [
      'attender',
      'warden',
    ]).get();
    recepients = querySnapshot.docs.map((e) {
      UserData user = UserData();
      user.email = e.id;
      return user;
    }).toList();
    setState(() {
      _userFetchLoading = false;
    });
  }

  void _save() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      complaint.imgUrl = img != null
          ? await uploadImage(
              context,
              img,
              "${complaint.from}/complaint-image",
              complaint.id,
            )
          : complaint.imgUrl;
      if (widget.id == null) {
        complaint.id = DateTime.now().millisecondsSinceEpoch.toString();
        debugPrint(
            "creating new complaint with id: ${DateTime.now().millisecondsSinceEpoch}");
      }
      await widget.onSubmit(complaint);
      if (context.mounted) {
        Navigator.of(context).pop(complaint);
      }
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
    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileImage(
            url: complaint.imgUrl,
            onChanged: (value) {
              img = value;
            },
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(
              icon: _userFetchLoading
                  ? circularProgressIndicator()
                  : const Icon(Icons.person_add_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Add a recepient'),
            ),
            value: (widget.id != null && !_userFetchLoading
                ? complaint.to[0]
                : null),
            validator: (value) => value == null ? "Select a user" : null,
            items: recepients
                .map(
                  (e) => DropdownMenuItem(
                    value: e.email,
                    child: Text(e.email!),
                  ),
                )
                .toList(),
            onChanged: ((value) => complaint.to = [value!.toString()]),
          ),
          TextFormField(
            onChanged: (value) {
              complaint.title = value;
            },
            key: UniqueKey(),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              icon: const Icon(Icons.title_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Title'),
            ),
            initialValue: complaint.title,
            enabled: !_loading,
            validator: (value) => Validate.text(value),
            onSaved: (value) {
              complaint.title = value!.trim();
            },
          ),
          TextFormField(
            onChanged: (value) {
              complaint.description = value;
            },
            key: UniqueKey(),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: null,
            decoration: InputDecoration(
              icon: const Icon(Icons.description_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Description'),
            ),
            initialValue: complaint.description,
            enabled: !_loading,
            validator: (value) => Validate.text(value, required: false),
            onSaved: (value) {
              complaint.description = value!.trim();
            },
          ),
          DropdownButtonFormField(
            key: UniqueKey(),
            decoration: InputDecoration(
              icon: const Icon(Icons.public_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Scope'),
            ),
            value: complaint.scope.index,
            validator: (value) => value == null ? "Select a scope" : null,
            items: Scope.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e.index,
                    child: Text(e.name),
                  ),
                )
                .toList(),
            onChanged: ((value) => complaint.scope = Scope.values[value ?? 0]),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: const Icon(
                  Icons.report_rounded,
                ),
                label: _loading
                    ? circularProgressIndicator()
                    : const Text('Submit'),
              ),
              ElevatedButton.icon(
                onPressed: _userFetchLoading
                    ? null
                    : () {
                        _formkey.currentState!.reset();
                        initialize();
                      },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: _userFetchLoading
                    ? circularProgressIndicator()
                    : const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
