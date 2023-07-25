import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/widgets/chat/user_tile.dart';

// ignore: must_be_immutable
class MultiChooser extends StatefulWidget {
  final List<String> allOptions;
  List<String> chosenOptions;
  final void Function(List<String> chosenOptions) onUpdate;
  final String label;
  final String hintTxt;
  MultiChooser({
    super.key,
    required this.allOptions,
    this.chosenOptions = const [],
    required this.onUpdate,
    required this.label,
    required this.hintTxt,
  }) {
    if (chosenOptions.isEmpty) chosenOptions = [];
  }

  @override
  State<MultiChooser> createState() => _MultiChooserState();
}

class _MultiChooserState extends State<MultiChooser> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final users = widget.allOptions
        .where((element) => !widget.chosenOptions.contains(element));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label),
            DropdownMenu(
              key: ValueKey("users_drop_down_menu_$i"),
              enabled: users.isNotEmpty,
              // width: MediaQuery.of(context).size.width * 3 / 4,
              dropdownMenuEntries: users
                  .map((e) => DropdownMenuEntry(label: e, value: e))
                  .toList(),
              label: Text(widget.hintTxt),
              hintText: 'attender@iiitr.ac.in',
              leadingIcon: const Icon(Icons.person_add_alt_1_rounded),
              onSelected: (value) {
                setState(() {
                  widget.chosenOptions.add(value!.toString());
                  i++;
                });
                widget.onUpdate(widget.chosenOptions);
              },
              initialSelection: null,
            ),
            Wrap(
              children: widget.chosenOptions
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
      widget.chosenOptions.remove(user.email);
      i--;
    });
  }
}
