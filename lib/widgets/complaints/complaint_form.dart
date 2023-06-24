import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/user.dart';

import 'package:hustle_stay/tools.dart';

class ComplaintForm extends StatefulWidget {
  String? id;
  final Future<ComplaintData> Function(ComplaintData) onSubmit;
  ComplaintForm({super.key, required this.onSubmit, this.id});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formkey = GlobalKey<FormState>();

  bool _loading = false;
  bool _userFetchLoading = true;
  late ComplaintData complaint;

  List<UserData> recepients = [];

  @override
  void initState() {
    super.initState();
    complaint = ComplaintData(
      from: currentUser.email!,
      id: widget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: "",
      to: [],
    );
    initialize();
  }

  Future<void> initialize() async {
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
      complaint = await widget.onSubmit(complaint);
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
          DropdownButtonFormField(
            decoration: InputDecoration(
              icon: _userFetchLoading
                  ? circularProgressIndicator()
                  : const Icon(Icons.person_add_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Add a recepient'),
            ),
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
          ElevatedButton.icon(
            onPressed: _loading ? null : _save,
            icon: const Icon(
              Icons.report_rounded,
            ),
            label:
                _loading ? circularProgressIndicator() : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
