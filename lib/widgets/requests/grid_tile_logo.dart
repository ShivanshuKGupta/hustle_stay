import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class GridTileLogo extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color color;
  final void Function()? onTap;
  const GridTileLogo({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: title,
      child: GlassWidget(
        radius: 30,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: color.withOpacity(0.2),
            padding: const EdgeInsets.all(10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  icon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
