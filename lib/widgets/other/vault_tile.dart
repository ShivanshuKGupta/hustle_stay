import 'package:flutter/material.dart';

class VaultTile<String> extends StatelessWidget {
  final String value;
  final void Function(String value)? onTap;
  final void Function(String value) onRemove;
  const VaultTile({
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
