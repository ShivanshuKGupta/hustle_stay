import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class MessRequestScreen extends StatelessWidget {
  const MessRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: 'Mess Requests',
          style:
              theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: [
                  GridTileLogo(
                    onTap: () {
                      // code
                    },
                    title: 'Breakfast',
                    icon: const Icon(
                      Icons.local_cafe,
                      size: 50,
                    ),
                    color: Colors.pinkAccent,
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Lunch',
                    icon: const Icon(
                      Icons.restaurant,
                      size: 50,
                    ),
                    color: Colors.deepPurpleAccent,
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Snacks',
                    icon: const Icon(
                      Icons.fastfood,
                      size: 50,
                    ),
                    color: Colors.cyanAccent,
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Dinner',
                    icon: const Icon(
                      Icons.local_dining,
                      size: 50,
                    ),
                    color: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
