import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/chat/user_tile.dart';

class ChooseUsers extends StatefulWidget {
  final List<String> allUsers;
  List<String> chosenUsers;
  final void Function(List<String> newEmails) onUpdate;
  ChooseUsers({
    super.key,
    required this.allUsers,
    this.chosenUsers = const [],
    required this.onUpdate,
  });

  @override
  State<ChooseUsers> createState() => _ChooseUsersState();
}

class _ChooseUsersState extends State<ChooseUsers> {
  // final _controller = TextEditingController();

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // _controller.clear();
    final users = widget.allUsers
        .where((element) => !widget.chosenUsers.contains(element));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu(
          key: UniqueKey(),
          enabled: users.isNotEmpty,
          // controller: _controller,
          dropdownMenuEntries:
              users.map((e) => DropdownMenuEntry(label: e, value: e)).toList(),
          label: const Text("Select a receipient"),
          hintText: 'attender@iiitr.ac.in',
          leadingIcon: const Icon(Icons.person_add_alt_1_rounded),
          width: MediaQuery.of(context).size.width - 40,
          onSelected: (value) {
            setState(() {
              widget.chosenUsers.add(value!.toString());
            });
            widget.onUpdate(widget.chosenUsers);
          },
          initialSelection: null,
        ),
        Wrap(
          children: widget.chosenUsers
              .map((e) =>
                  UserTile(key: ValueKey(e), email: e, removeUser: _remove))
              .toList(),
        ),
      ],
    );
  }

  void _remove(UserData user) {
    setState(() {
      widget.chosenUsers.remove(user.email);
    });
  }
}
