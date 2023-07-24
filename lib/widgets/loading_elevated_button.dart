import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class LoadingElevatedButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget icon;
  final Widget label;
  final ButtonStyle? style;
  final bool enabled;
  const LoadingElevatedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style,
    this.enabled = true,
  });

  @override
  State<LoadingElevatedButton> createState() => _LoadingElevatedButtonState();
}

class _LoadingElevatedButtonState extends State<LoadingElevatedButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: widget.style,
      onPressed: _loading || !widget.enabled
          ? null
          : () async {
              setState(() {
                _loading = true;
              });
              try {
                await widget.onPressed();
              } catch (e) {
                showMsg(context, e.toString());
              }
              if (context.mounted) {
                setState(() {
                  _loading = false;
                });
              }
            },
      icon: _loading ? circularProgressIndicator() : widget.icon,
      label: widget.label,
    );
  }
}
