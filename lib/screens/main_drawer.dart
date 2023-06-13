import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/settings_screen.dart';

import 'package:hustle_stay/tools.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }

  Widget body(context) {
    final auth = FirebaseAuth.instance;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          leading: const CircleAvatar(
            child: Icon(Icons.person_rounded),
          ),
          title: Text(
            auth.currentUser!.displayName ?? "Display Name",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            auth.currentUser!.email!,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onTap: () {
            // TODO: add a profile screen
            showMsg(context, 'TODO: add a profile screen');
          },
        ),
        const Divider(),
        _drawerTile(
          context,
          title: "Attendance",
          icon: Icons.co_present_rounded,
          subtitle: "View/Take Attendance",
          onTap: () {
            // TODO: Add a attendance screen
            showMsg(context, "TODO: Add a attendance screen");
          },
        ),
        _drawerTile(
          context,
          title: "Complaint",
          icon: Icons.question_answer_rounded,
          subtitle: "View/Post Complaints",
          onTap: () {
            // TODO: Add a Complaint screen
            showMsg(context, "TODO: Add a Complaint screen");
          },
        ),
        _drawerTile(
          context,
          title: "Vehicle Request",
          icon: Icons.airport_shuttle_rounded,
          subtitle: "Make/Manage Vehicle Requests",
          onTap: () {
            // TODO: Add a Vehicle Request screen
            showMsg(context, "TODO: Add a Vehicle Request screen");
          },
        ),
        _drawerTile(
          context,
          title: "Settings",
          icon: Icons.settings_rounded,
          subtitle: "Customize the app to your needs",
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
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
