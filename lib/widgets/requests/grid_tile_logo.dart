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
    return GlassWidget(
      radius: 30,
      child: Container(
        color: color.withOpacity(0.2),
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: onTap,
          child: GridTile(
            header: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
