import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SelectionVault extends StatefulWidget {
  final List<String> allItems;
  final String? helpText;
  List<String> chosenItems;
  final void Function(List<String> chosenItems) onChange;
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
          (e) => _VaultTile(
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
                    if (widget.chosenItems.isEmpty) widget.chosenItems = [];
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
                  widget.chosenItems = widget.allItems.map((e) => e).toList();
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

class _VaultTile<String> extends StatelessWidget {
  final String value;
  final void Function(String value)? onTap;
  final void Function(String value) onRemove;
  const _VaultTile({
    super.key,
    required this.value,
    this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => (onTap ?? onRemove)(value),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        padding: const EdgeInsets.only(left: 10),
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
              child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 20,
                  child: Icon(Icons.close_rounded, size: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
