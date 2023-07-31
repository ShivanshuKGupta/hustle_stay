import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/filter_screen/select_one_tile.dart';

// ignore: must_be_immutable
class SelectMany<T> extends StatefulWidget {
  final Set<T> allOptions;
  Set<T> selectedOptions;
  final void Function(Set<T> chosenOption) onChange;
  final String? title;
  final String? subtitle;
  bool expanded;
  TextStyle? style;
  EdgeInsets? padding;
  SelectMany({
    super.key,
    required this.allOptions,
    this.selectedOptions = const {},
    required this.onChange,
    this.title,
    this.subtitle,
    this.style,
    this.padding,
    this.expanded = false,
  });

  @override
  State<SelectMany<T>> createState() => _SelectManyState<T>();
}

class _SelectManyState<T> extends State<SelectMany<T>> {
  @override
  Widget build(BuildContext context) {
    final Wrap body = Wrap(
      // alignment: WrapAlignment.center,
      // crossAxisAlignment: WrapCrossAlignment.center,
      // runAlignment: WrapAlignment.center,
      runSpacing: 0,
      spacing: 5,
      children: widget.allOptions
          .map((e) => SelectOneTile(
                label: e.toString(),
                isSelected: widget.selectedOptions.contains(e),
                onPressed: () {
                  setState(() {
                    if (widget.selectedOptions.contains(e)) {
                      widget.selectedOptions.remove(e);
                    } else {
                      widget.selectedOptions.add(e);
                    }
                  });
                  widget.onChange(widget.selectedOptions);
                },
              ))
          .toList(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding:
                widget.padding ?? const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title!,
                      style:
                          widget.style ?? Theme.of(context).textTheme.bodyLarge,
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
                      widget.expanded = !widget.expanded;
                    });
                  },
                  icon: Icon(widget.expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),
        if (widget.expanded)
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
