import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/image.dart';
import 'package:hustle_stay/tools.dart';

import '../../widgets/edit_profile.dart';

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
        body: EditProfileWidget(
          user: widget.user,
        ));
  }
}
