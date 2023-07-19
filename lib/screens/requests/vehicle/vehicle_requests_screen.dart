import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_request_form_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class VehicleRequestScreen extends StatelessWidget {
  static const String routeName = 'VanRequestScreen';
  const VehicleRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GridTileLogo(
              onTap: () {
                Navigator.of(context).pop();
              },
              title: 'Vehicle',
              icon: Icon(
                Request.uiElements['Vehicle']!['icon'],
                size: 50,
              ),
              color: theme.colorScheme.background,
            ),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: (Request.uiElements['Vehicle']!['children']
                        as Map<String, dynamic>)
                    .entries
                    .map(
                      (entry) => GridTileLogo(
                        onTap: () {
                          navigatorPush(
                            context,
                            VehicleRequestFormScreen(
                              title: entry.key,
                              icon: Icon(
                                entry.value['icon'],
                                size: 50,
                              ),
                              reasonOptions: entry.value['reasonOptions'],
                            ),
                          );
                        },
                        title: entry.key,
                        icon: Icon(
                          entry.value['icon'],
                          size: 50,
                        ),
                        color: entry.value['color'],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
