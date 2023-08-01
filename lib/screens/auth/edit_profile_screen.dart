import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/widgets/edit_profile.dart';
import 'package:hustle_stay/widgets/settings/sign_out_button.dart';

class EditProfile extends ConsumerWidget {
  late final UserData user;

  EditProfile({super.key, UserData? user}) {
    this.user = user ?? UserData();
  }

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [if (user.email == currentUser.email) const SignOutButton()],
      ),
      body: EditProfileWidget(
        user: user,
      ),
    );
  }
}
