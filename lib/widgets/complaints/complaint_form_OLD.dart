import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/multi_choser.dart';

// ignore: must_be_immutable
class ComplaintFormOLD extends StatefulWidget {
  ComplaintData? complaint;
  final Category? category;
  final Future<void> Function(ComplaintData) onSubmit;
  ComplaintFormOLD(
      {super.key, required this.onSubmit, this.complaint, this.category}) {
    if (complaint != null && category != null) {
      throw 'Complaint and category both can\'t be given at the same time';
    }
  }

  @override
  State<ComplaintFormOLD> createState() => _ComplaintFormOLDState();
}

class _ComplaintFormOLDState extends State<ComplaintFormOLD> {
  final _formkey = GlobalKey<FormState>();

  bool _loading = false;
  bool _userFetchLoading = false;

  late ComplaintData complaint;

  List<String> recepients = [];

  File? img;

  @override
  void initState() {
    super.initState();
    complaint = widget.complaint ??
        ComplaintData(
          from: currentUser.email!,
          id: 0,
          to: [],
          category: widget.category == null ? null : widget.category!.id,
        );
    initialize();
  }

  Future<void> initialize() async {
    if (context.mounted) setState(() => _userFetchLoading = true);
    if (widget.complaint != null) {
      try {
        complaint = await fetchComplaint(widget.complaint!.id);
      } catch (e) {
        await askUser(
          context,
          "Can't fetch this complaint (id: ${widget.complaint!.id})",
          description: e.toString(),
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }
    recepients = (await fetchComplainees()).map((e) => e.email!).toList();
    if (context.mounted) setState(() => _userFetchLoading = false);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState!.validate()) return;
    if (complaint.category != null && complaint.category != "Other") {
      complaint.to =
          (await fetchCategory(complaint.category!)).defaultReceipient;
    }
    if (complaint.to.isEmpty) {
      // ignore: use_build_context_synchronously
      showMsg(context, 'Add a receipeint');
      return;
    }
    _formkey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      // complaint.imgUrl = img != null
      //     // ignore: use_build_context_synchronously
      //     ? await uploadImage(
      //         context,
      //         img,
      //         "${complaint.from}/complaint-image",
      //         complaint.id.toString(),
      //       )
      //     : complaint.imgUrl;
      if (complaint.id == 0) {
        complaint.id = DateTime.now().millisecondsSinceEpoch;
      }
      await widget.onSubmit(complaint);
      if (context.mounted && context.mounted) {
        Navigator.of(context).pop(complaint);
      }
      return;
    } catch (e) {
      if (context.mounted) {
        showMsg(context, e.toString());
      }
    }
    if (context.mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ProfileImage(
          //   url: complaint.imgUrl,
          //   onChanged: (value) {
          //     img = value;
          //   },
          // ),
          // const SizedBox(
          //   height: 20,
          // ),

          // TextFormField(
          //   onChanged: (value) {
          //     complaint.title = value;
          //   },
          //   keyboardType: TextInputType.text,
          //   decoration: InputDecoration(
          //     icon: const Icon(Icons.title_rounded),
          //     iconColor: Theme.of(context).colorScheme.onBackground,
          //     label: const Text('Title'),
          //   ),
          //   initialValue: complaint.title,
          //   enabled: !_loading,
          //   validator: (value) => Validate.text(value),
          //   onSaved: (value) {
          //     complaint.title = value!.trim();
          //   },
          // ),
          TextFormField(
            onChanged: (value) {
              complaint.description = value;
            },
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
          // TODO: add a categories builder
          CategoriesBuilder(
            builder: (ctx, categories) => DropdownButtonFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.category_rounded),
                iconColor: Theme.of(context).colorScheme.onBackground,
                label: const Text('Category'),
              ),
              value: complaint.category,
              validator: (value) => value == null ? "Select a category" : null,
              items: categories
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.id),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  complaint.category = value ?? "Other";
                });
              },
              onSaved: (value) => complaint.category = value ?? "Other",
            ),
          ),
          if (complaint.category == null || complaint.category == 'Other')
            (_userFetchLoading)
                ? circularProgressIndicator()
                : MultiChooser(
                    hintTxt: "Select a receipient",
                    label: 'Complainees',
                    allOptions: recepients,
                    chosenOptions: complaint.to,
                    onUpdate: (value) => complaint.to = value,
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
