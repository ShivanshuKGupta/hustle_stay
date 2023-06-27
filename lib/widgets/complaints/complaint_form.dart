import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/image.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/choose_users.dart.dart';
import 'package:hustle_stay/widgets/profile_image.dart';

class ComplaintForm extends StatefulWidget {
  ComplaintData? complaint;
  final Future<void> Function(ComplaintData) onSubmit;
  ComplaintForm({super.key, required this.onSubmit, this.complaint});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formkey = GlobalKey<FormState>();

  bool _loading = false;
  bool _userFetchLoading = false;
  bool _disposed = false;
  List<String> recepients = [];

  File? img;

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

  @override
  void initState() {
    super.initState();
    widget.complaint = widget.complaint ??
        ComplaintData(
          from: currentUser.email!,
          id: "",
          title: "",
          to: [],
          resolved: false,
        );
    initialize();
  }

  Future<void> initialize() async {
    if (!_disposed) setState(() => _userFetchLoading = true);
    if (widget.complaint != null && widget.complaint!.id.isNotEmpty) {
      try {
        widget.complaint = await fetchComplaint(widget.complaint!.id);
      } catch (e) {
        await askUser(context, e.toString());
        if (!_disposed && context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }
    final querySnapshot =
        await firestore.collection('users').where('type', whereIn: [
      'attender',
      'warden',
    ]).get();
    recepients = querySnapshot.docs.map((e) => e.id).toList();
    if (!_disposed) setState(() => _userFetchLoading = false);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState!.validate()) return;
    if (widget.complaint!.to.isEmpty) {
      showMsg(context, 'Add a receipeint');
      return;
    }
    _formkey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      widget.complaint!.imgUrl = img != null
          ? await uploadImage(
              context,
              img,
              "${widget.complaint!.from}/complaint-image",
              widget.complaint!.id,
            )
          : widget.complaint!.imgUrl;
      if (widget.complaint!.id.isEmpty) {
        widget.complaint!.id = DateTime.now().millisecondsSinceEpoch.toString();
      }
      await widget.onSubmit(widget.complaint!);
      if (!_disposed && context.mounted) {
        Navigator.of(context).pop(widget.complaint!);
      }
      return;
    } catch (e) {
      showMsg(context, e.toString());
    }
    if (!_disposed) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileImage(
            url: widget.complaint!.imgUrl,
            onChanged: (value) {
              img = value;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          (_userFetchLoading)
              ? circularProgressIndicator()
              : ChooseUsers(
                  allUsers: recepients,
                  chosenUsers: widget.complaint!.to,
                  onUpdate: (value) => widget.complaint!.to = value,
                ),
          TextFormField(
            onChanged: (value) {
              widget.complaint!.title = value;
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              icon: const Icon(Icons.title_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Title'),
            ),
            initialValue: widget.complaint!.title,
            enabled: !_loading,
            validator: (value) => Validate.text(value),
            onSaved: (value) {
              widget.complaint!.title = value!.trim();
            },
          ),
          TextFormField(
            onChanged: (value) {
              widget.complaint!.description = value;
            },
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: null,
            decoration: InputDecoration(
              icon: const Icon(Icons.description_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Description'),
            ),
            initialValue: widget.complaint!.description,
            enabled: !_loading,
            validator: (value) => Validate.text(value, required: false),
            onSaved: (value) {
              widget.complaint!.description = value!.trim();
            },
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(
              icon: const Icon(Icons.public_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Scope'),
            ),
            value: widget.complaint!.scope.index,
            validator: (value) => value == null ? "Select a scope" : null,
            items: Scope.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e.index,
                    child: Text(e.name),
                  ),
                )
                .toList(),
            onChanged: ((value) =>
                widget.complaint!.scope = Scope.values[value ?? 0]),
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
