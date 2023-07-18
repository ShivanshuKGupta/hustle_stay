import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class AttendanceRequestScreen extends StatelessWidget {
  const AttendanceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: shaderText(
          context,
          title: 'Attendance Request',
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
                    title: 'Change Room',
                    icon: const Icon(
                      Icons.transfer_within_a_station_rounded,
                      size: 50,
                    ),
                    color: Colors.blueAccent,
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Swap Room',
                    icon: const Icon(
                      Icons.transfer_within_a_station_rounded,
                      size: 50,
                    ),
                    color: Colors.pinkAccent,
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Leave Request',
                    icon: const Icon(
                      Icons.exit_to_app_rounded,
                      size: 50,
                    ),
                    color: Colors.indigoAccent,
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Return Request',
                    icon: const Icon(
                      Icons.keyboard_return_rounded,
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
