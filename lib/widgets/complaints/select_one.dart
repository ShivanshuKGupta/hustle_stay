import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/filter_screen/select_one_tile.dart';

// ignore: must_be_immutable
class SelectOne<T> extends StatefulWidget {
  final List<T> allOptions;
  T? selectedOption;
  final bool Function(T chosenOption) onChange;
  final String? title;
  SelectOne({
    super.key,
    required this.allOptions,
    this.selectedOption,
    required this.onChange,
    this.title,
  });

  @override
  State<SelectOne<T>> createState() => _SelectOneState<T>();
}

class _SelectOneState<T> extends State<SelectOne<T>> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final Wrap body = Wrap(
      alignment: WrapAlignment.center,
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
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.bodyLarge,
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
