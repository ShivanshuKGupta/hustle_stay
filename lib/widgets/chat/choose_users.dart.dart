import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/widgets/chat/user_tile.dart';

// ignore: must_be_immutable
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
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final users = widget.allUsers
        .where((element) => !widget.chosenUsers.contains(element));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Complainees'),
            DropdownMenu(
              key: ValueKey("users_drop_down_menu_$i"),
              enabled: users.isNotEmpty,
              // width: MediaQuery.of(context).size.width * 3 / 4,
              dropdownMenuEntries: users
                  .map((e) => DropdownMenuEntry(label: e, value: e))
                  .toList(),
              label: const Text("Select a receipient"),
              hintText: 'attender@iiitr.ac.in',
              leadingIcon: const Icon(Icons.person_add_alt_1_rounded),
              onSelected: (value) {
                setState(() {
                  widget.chosenUsers.add(value!.toString());
                  i++;
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
        ),
      ),
    );
  }

  void _remove(UserData user) {
    setState(() {
      widget.chosenUsers.remove(user.email);
      i--;
    });
  }
}
