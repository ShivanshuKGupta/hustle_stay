import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class VanRequestScreen extends StatelessWidget {
  const VanRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: 'Vehicle Request',
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
                      navigatorPush(context, Container());
                    },
                    title: 'Night Travel',
                    icon: const Icon(
                      Icons.nightlight_round,
                      size: 50,
                    ),
                    color: Colors.blueAccent,
                  ),
                  GridTileLogo(
                    onTap: () {
                      navigatorPush(context, Container());
                    },
                    title: 'Hospital Visit',
                    icon: const Icon(
                      Icons.local_hospital_rounded,
                      size: 50,
                    ),
                    color: Colors.tealAccent,
                  ),
                  GridTileLogo(
                    onTap: () {
                      navigatorPush(context, Container());
                    },
                    title: 'Medical Emergency',
                    icon: const Icon(
                      Icons.warning_rounded,
                      size: 50,
                    ),
                    color: Colors.redAccent,
                  ),
                  GridTileLogo(
                    onTap: () {
                      navigatorPush(context, Container());
                    },
                    title: 'Other Reason',
                    icon: const Icon(
                      Icons.more_horiz_rounded,
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
