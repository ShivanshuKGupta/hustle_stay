import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/filter_screen/select_one_tile.dart';

// ignore: must_be_immutable
class SelectOne<T> extends StatefulWidget {
  final Set<T> allOptions;
  T? selectedOption;
  final bool Function(T chosenOption) onChange;
  final String? title;
  final String? subtitle;
  SelectOne({
    super.key,
    required this.allOptions,
    this.selectedOption,
    required this.onChange,
    this.title,
    this.subtitle,
  });

  @override
  State<SelectOne<T>> createState() => _SelectOneState<T>();
}

class _SelectOneState<T> extends State<SelectOne<T>> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final Wrap body = Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 0,
      spacing: 5,
      children: widget.allOptions
          .map((e) => SelectOneTile(
                label: e.toString(),
                isSelected: widget.selectedOption == e,
                onPressed: () {
                  if (widget.onChange(e)) {
                    setState(() {
                      widget.selectedOption = e;
                    });
                  }
                },
              ))
          .toList(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  icon: Icon(expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),
        if (expanded)
          body
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: body,
          ),
      ],
    );
  }
}
