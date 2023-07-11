// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class SelectionVault extends StatefulWidget {
  final List<String> allItems;
  final String? helpText;
  List<String> chosenItems;
  final void Function(List<String> chosenItems) onChange;
  SelectionVault({
    super.key,
    required this.allItems,
    required this.onChange,
    this.chosenItems = const [],
    this.helpText,
  });

  @override
  State<SelectionVault> createState() => _SelectionVaultState();
}

class _SelectionVaultState extends State<SelectionVault> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        ...widget.chosenItems.map(
          (e) => _VaultTile(
            value: e,
            onTap: (value) {
              askUser(context, e.toString());
            },
            onRemove: (value) {
              setState(() {
                widget.chosenItems.remove(value);
              });
              widget.onChange(widget.chosenItems);
            },
          ),
        ),
        if (widget.chosenItems.isEmpty)
          OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded),
            label: Text(widget.helpText ?? ''),
          )
        else
          IconButton(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded),
          ),
      ],
    );
  }

  void _add() async {
    final String? value = await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.helpText ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              DropdownMenu(
                menuHeight: 500,
                width: MediaQuery.of(context).size.width - 100,
                enabled: widget.allItems.isNotEmpty,
                enableSearch: true,
                enableFilter: true,
                onSelected: (value) {
                  Navigator.of(context).pop(value);
                },
                dropdownMenuEntries: widget.allItems
                    .where((element) => !widget.chosenItems.contains(element))
                    .map(
                      (e) => DropdownMenuEntry(
                        value: e,
                        label: e.toString(),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
    if (value == null) return;
    setState(() {
      if (widget.chosenItems.isEmpty) widget.chosenItems = [];
      widget.chosenItems.add(value);
    });
    widget.onChange(widget.chosenItems);
  }
}

class _VaultTile<String> extends StatelessWidget {
  final String value;
  final void Function(String value) onTap, onRemove;
  const _VaultTile({
    super.key,
    required this.value,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            InkWell(
              onTap: () => onRemove(value),
              borderRadius: BorderRadius.circular(30),
              child: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
