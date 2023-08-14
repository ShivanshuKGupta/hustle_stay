import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/admin_panel/admin_panel_screen.dart';
import 'package:hustle_stay/screens/chat/private_chats.dart';
import 'package:hustle_stay/screens/drawers/main_drawer.dart';
import 'package:hustle_stay/screens/filter_screen/stats_screen.dart';
import 'package:hustle_stay/screens/medical_screen/medical_screen.dart';
import 'package:hustle_stay/screens/profile/profile_preview.dart';
import 'package:hustle_stay/screens/requests/stats/requests_stats_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/dark_light_mode_icon_button.dart';

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
      ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        leading: const Icon(Icons.medical_information_rounded),
        title: const Text('Filter Medical Info'),
        subtitle:
            const Text('Filter people based on their medical information'),
        tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        onTap: () {
          navigatorPush(context, const MedicalScreen());
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
    ];
    return Scaffold(
      appBar: AppBar(
        // title: shaderText(
        //   context,
        //   style: Theme.of(context).textTheme.titleLarge!.copyWith(
        //         fontWeight: FontWeight.bold,
        //       ),
        //   title: 'Your Profile',
        // ),
        actions: const [
          DarkLightModeIconButton(),
        ],
      ),
      drawer: kDebugMode ? const MainDrawer() : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.separated(
                itemCount: children.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 5),
                itemBuilder: (ctx, index) => children[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
