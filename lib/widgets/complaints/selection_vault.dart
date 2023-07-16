import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/complaints/vault_tile.dart';

// ignore: must_be_immutable
class SelectionVault extends StatefulWidget {
  final Set<String> allItems;
  final String? helpText;
  Set<String> chosenItems;
  final void Function(Set<String> chosenItems) onChange;
  SelectionVault({
    super.key,
    required this.allItems,
    required this.onChange,
    required this.chosenItems,
    this.helpText,
  });

  @override
  State<SelectionVault> createState() => _SelectionVaultState();
}

class _SelectionVaultState extends State<SelectionVault> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        ...widget.chosenItems.map(
          (e) => VaultTile(
            value: e,
            onRemove: (value) {
              setState(() {
                widget.chosenItems.remove(value);
              });
              widget.onChange(widget.chosenItems);
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.fromBorderSide(
              BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: DropdownButton(
              key: UniqueKey(),
              iconSize: 24,
              style: Theme.of(context).textTheme.bodyMedium,
              isDense: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              borderRadius: BorderRadius.circular(20),
              disabledHint: const Text('No options available'),
              hint: Text(widget.helpText ?? "Choose an option"),
              icon: const Icon(Icons.add_rounded),
              underline: Container(),
              items: widget.allItems
                  .where((element) => !widget.chosenItems.contains(element))
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    if (widget.chosenItems.isEmpty) widget.chosenItems = {};
                    widget.chosenItems.add(value);
                  });
                  _textEditingController.clear();
                  widget.onChange(widget.chosenItems);
                }
              }),
        ),
        if (widget.allItems.isNotEmpty)
          TextButton(
            key: UniqueKey(),
            onPressed: () {
              setState(() {
                if (widget.chosenItems.length == widget.allItems.length) {
                  widget.chosenItems.clear();
                } else {
                  widget.chosenItems = widget.allItems.map((e) => e).toSet();
                }
              });
              widget.onChange(widget.chosenItems);
            },
            child: Text(
                '${widget.chosenItems.length == widget.allItems.length ? 'Deselect' : 'Select'} all'),
          ),
      ],
    );
  }
}
