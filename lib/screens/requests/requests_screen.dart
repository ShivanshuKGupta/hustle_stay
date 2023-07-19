import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/requests/van/van_request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/screens/requests/attendance/attendance_request_screen.dart';
import 'package:hustle_stay/screens/requests/mess/mess_request_screen.dart';
import 'package:hustle_stay/screens/requests/van/van_requests_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            CacheBuilder(
              builder: (ctx, data) {
                final children = data.map((e) => e.widget(context)).toList();
                if (children.isNotEmpty) {
                  children.insert(
                    0,
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 15),
                      child: shaderText(
                        context,
                        title: 'Your Requests',
                        style: theme.textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (ctx, index) {
                    return children[index];
                  },
                );
              },
              provider: getStudentRequests,
            ),
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
                  onTap: () {
                    navigatorPush(context, const AttendanceRequestScreen());
                  },
                  title: 'Attendance',
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 50,
                  ),
                  color: Colors.red,
                ),
                GridTileLogo(
                  onTap: () {
                    navigatorPush(context, const VanRequestScreen());
                  },
                  title: 'Vehicle',
                  icon: const Icon(
                    Icons.airport_shuttle_rounded,
                    size: 50,
                  ),
                  color: Colors.deepPurpleAccent,
                ),
                GridTileLogo(
                  onTap: () {
                    navigatorPush(context, const MessRequestScreen());
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
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Request>> getStudentRequests({Source? src}) async {
    final collection = firestore.collection('requests');
    final response = await collection
        .where('requestingUserEmail', isEqualTo: currentUser.email)
        .where(
          'expiryDate',
          isGreaterThan: DateTime.now().millisecondsSinceEpoch,
        )
        .get(src == null ? null : GetOptions(source: src));
    final docs = response.docs;
    Set<String> requestTypes = {};
    List<Request> requests = docs.map((doc) {
      final data = doc.data();
      final type = data['type'];
      requestTypes.add(type);
      if (type == 'VanRequest') {
        return VanRequest(requestingUserEmail: data['requestingUserEmail'])
          ..load(data);
      }
      throw "No such type exists: '$type'";
    }).toList();
    for (var e in requestTypes) {
      fetchApprovers(e, src: src);
    }
    return requests;
  }
}
