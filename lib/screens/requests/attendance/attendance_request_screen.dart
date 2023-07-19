import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class AttendanceRequestScreen extends StatelessWidget {
  static const String routeName = 'AttendanceRequestScreen';
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
          children: [
            GridTileLogo(
              onTap: () {
                Navigator.of(context).pop();
              },
              title: 'Attendance',
              icon: Icon(
                Request.uiElements['Attendance']!['icon'],
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
                children: [
                  GridTileLogo(
                    onTap: () {},
                    title: 'Change Room',
                    icon: Icon(
                      Request.uiElements['Attendance']!['Change Room']['icon'],
                      size: 50,
                    ),
                    color: Request.uiElements['Attendance']!['Change Room']
                        ['color'],
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Swap Room',
                    icon: Icon(
                      Request.uiElements['Attendance']!['Swap Room']['icon'],
                      size: 50,
                    ),
                    color: Request.uiElements['Attendance']!['Swap Room']
                        ['color'],
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Leave Hostel',
                    icon: Icon(
                      Request.uiElements['Attendance']!['Leave Hostel']['icon'],
                      size: 50,
                    ),
                    color: Request.uiElements['Attendance']!['Leave Hostel']
                        ['color'],
                  ),
                  GridTileLogo(
                    onTap: () {},
                    title: 'Return to Hostel',
                    icon: Icon(
                      Request.uiElements['Attendance']!['Return to Hostel']
                          ['icon'],
                      size: 50,
                    ),
                    color: Request.uiElements['Attendance']!['Return to Hostel']
                        ['color'],
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
