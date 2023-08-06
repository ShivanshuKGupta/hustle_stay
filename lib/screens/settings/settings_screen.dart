import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/about/about_screen.dart';
import 'package:hustle_stay/screens/admin_panel/admin_panel_screen.dart';
import 'package:hustle_stay/screens/chat/private_chats.dart';
import 'package:hustle_stay/screens/filter_screen/stats_screen.dart';
import 'package:hustle_stay/screens/help/help_screen.dart';
import 'package:hustle_stay/screens/medical_screen/medical_screen.dart';
import 'package:hustle_stay/screens/profile/profile_preview.dart';
import 'package:hustle_stay/screens/requests/stats/requests_stats_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/dark_light_mode_icon_button.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';
import 'package:hustle_stay/widgets/settings/sign_out_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      ProfilePreview(
        user: currentUser,
        showCallButton: false,
        showChatButton: false,
        showMailButton: false,
      ),
      // const CurrentUserTile(),
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: shaderText(context,
      //       title: 'Other Features',
      //       style: Theme.of(context).textTheme.bodyLarge),
      // ),

      ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        leading: const Icon(Icons.chat_outlined),
        title: const Text('Your Chats'),
        subtitle: const Text('View your all other chats here'),
        tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        onTap: () {
          navigatorPush(context, const ChatsScreen());
        },
      ),
      if (currentUser.isAdmin)
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          leading: const Icon(Icons.admin_panel_settings_rounded),
          title: const Text('Administrative Panel'),
          subtitle:
              const Text('Manage Users, Hostels, Categories and much more...'),
          tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          onTap: () {
            navigatorPush(context, const AdminPanel());
          },
        ),
      if (currentUser.permissions.complaints.read == true)
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          leading: const Icon(Icons.stacked_bar_chart_rounded),
          title: const Text('Complaint Statistics'),
          subtitle: const Text('Analyze and view complaints'),
          tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          onTap: () {
            navigatorPush(context, const StatisticsPage());
          },
        ),
      if (currentUser.permissions.requests.read == true)
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          leading: const Icon(Icons.stacked_bar_chart_rounded),
          title: const Text('Requests Statistics'),
          subtitle: const Text('Analyze and view requests'),
          tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          onTap: () {
            navigatorPush(context, const RequestsStatisticsPage());
          },
        ),

      const Divider(),
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                navigatorPush(context, const AboutScreen());
              },
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('About Us'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                navigatorPush(context, const HelpScreen());
              },
              icon: const Icon(Icons.help_outline_rounded),
              label: const Text('Help'),
            ),
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
            const SignOutButton(),
            ElevatedButton.icon(
              onPressed: () {
                navigatorPush(context, const MedicalScreen());
              },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Medical Emergency'),
            ),
          ],
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        title: shaderText(
          context,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          title: 'Settings',
        ),
        actions: const [DarkLightModeIconButton()],
      ),
      // drawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.separated(
          itemCount: children.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 15),
          itemBuilder: (ctx, index) => children[index],
        ),
      ),
    );
  }
}
