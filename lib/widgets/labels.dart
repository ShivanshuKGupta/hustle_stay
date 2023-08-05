import 'package:flutter/material.dart';
import 'package:hustle_stay/models/common/operation.dart';

class Labels extends StatelessWidget {
  const Labels({super.key, required this.list});
  final List<ColorLabel> list;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: list.map((colorLabel) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorLabel.color.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(colorLabel.label),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
