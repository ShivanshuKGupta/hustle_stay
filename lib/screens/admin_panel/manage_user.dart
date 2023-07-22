import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/edit_profile.dart';

import '../../models/user.dart';
import '../../widgets/edit_permission.dart';

class ManageUser extends StatefulWidget {
  ManageUser({super.key, UserData? user, this.edit = false}) {
    this.user = user ?? UserData();
  }

  late final UserData user;
  final bool edit;

  @override
  State<ManageUser> createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  bool editPermssions = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.edit == false
            ? null
            : editPermssions
                ? const Text('Edit Permissions')
                : Text('Manage ${widget.user.name}'),
        actions: [
          if (widget.edit)
            IconButton(
                onPressed: () {
                  setState(() {
                    editPermssions = !editPermssions;
                  });
                },
                icon: const Icon(Icons.manage_accounts))
        ],
      ),
      body: editPermssions
          ? EditPermissions(email: widget.user.email!)
          : EditProfileWidget(
              user: widget.user,
            ),
    );
  }
}
