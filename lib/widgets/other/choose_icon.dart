import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/other/search_icon.dart';

// ignore: must_be_immutable
class ChooseIconWidget extends StatefulWidget {
  IconData? chosenIcon;
  final void Function(IconData icon) onChange;
  ChooseIconWidget({super.key, this.chosenIcon, required this.onChange});

  @override
  State<ChooseIconWidget> createState() => _ChooseIconWidgetState();
}

class _ChooseIconWidgetState extends State<ChooseIconWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => SearchIconWidget(
              icon: widget.chosenIcon,
              onChange: (icon) {
                Navigator.of(context).pop();
                setState(() {
                  widget.chosenIcon = icon;
                });
                widget.onChange(widget.chosenIcon!);
              }),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.chosenIcon ?? Icons.category,
            size: 50,
          ),
          const Text('Edit Icon'),
        ],
      ),
    );
  }
}
