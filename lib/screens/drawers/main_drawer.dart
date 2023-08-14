import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/notifications/notifications.dart';
import 'package:hustle_stay/screens/about/about_screen.dart';
import 'package:hustle_stay/screens/category/edit_category_screen.dart';
import 'package:hustle_stay/screens/complaints/resolved_complaints_screen.dart';
import 'package:hustle_stay/screens/help/help_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';
import 'package:hustle_stay/widgets/settings/current_user_tile.dart';
import 'package:hustle_stay/widgets/settings/sign_out_button.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: body(context),
              ),
            ),
            footer(context),
          ],
        ),
      ),
    );
  }

  Widget body(context) {
    return Column(
      children: [
        const CurrentUserTile(),
        const Divider(),
        if (kDebugMode)
          _drawerTile(
            context,
            title: "Resolved Complaints",
            icon: Icons.person_add_rounded,
            subtitle: "View resolved complaints",
            onTap: () async {
              navigatorPush(
                context,
                ResolvedComplaintsScreen(),
              );
            },
          ),
        if (kDebugMode)
          _drawerTile(
            context,
            title: "Add a new category",
            icon: Icons.person_add_rounded,
            subtitle: "Categories are used in complaints and requests",
            onTap: () async {
              navigatorPush(
                context,
                const EditCategoryScreen(),
              );
            },
          ),
        _drawerTile(
          context,
          title: "How to use?",
          icon: Icons.help_rounded,
          subtitle: "Help on how to use the app",
          onTap: () {
            navigatorPush(context, const HelpScreen());
          },
        ),
        _drawerTile(
          context,
          title: "About us",
          icon: Icons.info_rounded,
          subtitle: "Know more about us and the app",
          onTap: () {
            navigatorPush(context, const AboutScreen());
          },
        ),
      ],
    );
  }

  Widget footer(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: constraints.maxWidth,
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              children: [
                if (kDebugMode)
                  LoadingElevatedButton(
                    icon: const Icon(Icons.abc_rounded),
                    label: const Text('Test notification'),
                    onPressed: () async {
                      await sendNotification(
                        title: "Title",
                        body: "Body",
                        to: (await fetchUserData('cs21b1024@iiitr.ac.in'))
                            .fcmToken!,
                      );
                    },
                  ),
                // if (kDebugMode)
                //   LoadingElevatedButton(
                //     icon: const Icon(Icons.temple_buddhist_rounded),
                //     label: const Text('Edit Category'),
                //     onPressed: () async {
                //       await navigatorPush(
                //         context,
                //         const EditCategoryScreen(
                //           id: 'Bullying',
                //         ),
                //       );
                //     },
                //   ),
                ValueListenableBuilder(
                  valueListenable: everythingInitialized,
                  builder: (context, value, child) {
                    return LoadingElevatedButton(
                      loading: value != null,
                      errorHandler: (err) {
                        everythingInitialized.value = null;
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(value ?? 'Refresh Local Database'),
                      onPressed: initializeEverything,
                    );
                  },
                ),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     navigatorPush(context, const AboutScreen());
                //   },
                //   icon: const Icon(Icons.info_outline_rounded),
                //   label: const Text('About Us'),
                // ),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     navigatorPush(context, const HelpScreen());
                //   },
                //   icon: const Icon(Icons.help_outline_outlined),
                //   label: const Text('Help'),
                // ),
                if (kDebugMode) const SignOutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _drawerTile(context,
      {required String title,
      required String subtitle,
      void Function()? onTap,
      IconData? icon}) {
    return ListTile(
        leading: icon == null ? null : Icon(icon),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: onTap);
  }
}
