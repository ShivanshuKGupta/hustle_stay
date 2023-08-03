import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/category/edit_category_screen.dart';
import 'package:hustle_stay/screens/complaints/resolved_complaints_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/settings/current_user_tile.dart';

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
            // TODO: Add a help screen
            showMsg(context, "TODO: Add a Help Screen");
          },
        ),
        _drawerTile(
          context,
          title: "About us",
          icon: Icons.info_rounded,
          subtitle: "Know more about us and the app",
          onTap: () {
            // TODO: add a about us page
            showMsg(context, "TODO: Add a About us Screen");
          },
        ),
      ],
    );
  }

  Widget footer(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        ListTile(
          contentPadding:
              const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          leading: const Icon(
            Icons.emergency_share_rounded,
            color: Colors.red,
          ),
          title: Text(
            'Medical Emergency',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.red),
          ),
          subtitle: Text(
            'Make emergency vehicle request and inform all wardens',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          onTap: () {
            // TODO: add a medical emergency screen
            showMsg(context, 'TODO: add a medical emergency screen');
          },
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
