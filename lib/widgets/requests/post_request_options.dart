import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/requests/requests_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class PostRequestOptions extends StatelessWidget {
  const PostRequestOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: shaderText(
            context,
            title: 'Post a New Request',
            style: theme.textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        GridView.extent(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          maxCrossAxisExtent: 320,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          children: [
            ...requestMainPageElements.entries.map(
              (entry) => GridTileLogo(
                onTap: () {
                  Navigator.of(context).pushNamed(entry.value['route']);
                },
                title: entry.key,
                icon: Icon(entry.value['icon'], size: 50),
                color: entry.value['color'],
              ),
            ),
          ],
        )
      ],
    );
  }
}
