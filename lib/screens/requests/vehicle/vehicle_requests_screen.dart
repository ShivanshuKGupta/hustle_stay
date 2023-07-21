import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/requests/requests_screen.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_request_form_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

Map<String, dynamic> allVehicleRequestsData = <String, dynamic>{
  'Night_Travel': {
    'color': Colors.blue,
    'icon': Icons.nightlight_round,
    'reasonOptions': [
      'Train Arrival',
      'Train Departure',
    ],
  },
  'Hospital_Visit': {
    'color': Colors.tealAccent,
    'icon': Icons.local_hospital_rounded,
    'reasonOptions': [
      'Fever',
      'Food Poisoning',
    ],
  },
  'Other': {
    'color': Colors.lightGreenAccent,
    'icon': Icons.more_horiz_rounded,
    'reasonOptions': <String>[],
  },
};

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
                requestMainPageElements['Vehicle']!['icon'],
                size: 50,
              ),
              color: theme.colorScheme.background,
            ),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: allVehicleRequestsData.entries
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
                        title: entry.key.replaceAll('_', ' '),
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
