import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/requests/van/van_request_form_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class VanRequestScreen extends StatelessWidget {
  const VanRequestScreen({super.key});

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
              icon: const Icon(
                Icons.airport_shuttle_rounded,
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => VanRequestFormScreen(
                            title: 'Night Travel',
                            icon: const Icon(
                              Icons.nightlight_round,
                              size: 50,
                            ),
                            reasonOptions: const [
                              'Train Arrival',
                              'Train Departure',
                            ],
                          ),
                        ),
                      );
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
                      navigatorPush(
                        context,
                        VanRequestFormScreen(
                          title: 'Hospital Visit',
                          icon: const Icon(
                            Icons.local_hospital_rounded,
                            size: 50,
                          ),
                          reasonOptions: const [
                            'Fever',
                            'Food Poisoning',
                          ],
                        ),
                      );
                    },
                    title: 'Hospital Visit',
                    icon: const Icon(
                      Icons.local_hospital_rounded,
                      size: 50,
                    ),
                    color: Colors.tealAccent,
                  ),
                  // GridTileLogo(
                  //   onTap: () {
                  //     navigatorPush(
                  //       context,
                  //       VanRequestFormScreen(
                  //         title: 'Medical Issue',
                  //         icon: const Icon(
                  //           Icons.warning_rounded,
                  //           size: 50,
                  //         ),
                  //         reasonOptions: const [
                  //           'Train Arrival',
                  //           'Train Departure',
                  //         ],
                  //       ),
                  //     );
                  //   },
                  //   title: 'Medical Emergency',
                  //   icon: const Icon(
                  //     Icons.warning_rounded,
                  //     size: 50,
                  //   ),
                  //   color: Colors.redAccent,
                  // ),
                  GridTileLogo(
                    onTap: () {
                      navigatorPush(
                        context,
                        VanRequestFormScreen(
                          title: 'Other Reason',
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            size: 50,
                          ),
                          reasonOptions: const [],
                        ),
                      );
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
