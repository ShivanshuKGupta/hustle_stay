import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/requests/attendance/attendance_request_screen.dart';
import 'package:hustle_stay/screens/requests/mess/mess_request_screen.dart';
import 'package:hustle_stay/screens/requests/van/van_requests_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class PoptRequestOptions extends StatelessWidget {
  const PoptRequestOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          children: [
            GridTileLogo(
              onTap: () async {
                await navigatorPush<bool?>(
                    context, const AttendanceRequestScreen());
              },
              title: 'Attendance',
              icon: const Icon(
                Icons.calendar_month_rounded,
                size: 50,
              ),
              color: Colors.red,
            ),
            GridTileLogo(
              onTap: () async {
                await navigatorPush<bool?>(context, const VanRequestScreen());
              },
              title: 'Vehicle',
              icon: const Icon(
                Icons.airport_shuttle_rounded,
                size: 50,
              ),
              color: Colors.deepPurpleAccent,
            ),
            GridTileLogo(
              onTap: () async {
                await navigatorPush<bool?>(context, const MessRequestScreen());
              },
              title: 'Mess',
              icon: const Icon(
                Icons.restaurant_menu_rounded,
                size: 50,
              ),
              color: Colors.lightBlueAccent,
            ),
            GridTileLogo(
              onTap: () {},
              title: 'Other',
              icon: const Icon(
                Icons.more_horiz_rounded,
                size: 50,
              ),
              color: Colors.amber,
            ),
          ],
        )
      ],
    );
  }
}
