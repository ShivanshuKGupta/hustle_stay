import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings'));
  }
}

// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final settingsClass = ref.read(settingsProvider.notifier);
//     const duration = Duration(milliseconds: 300);
//     final widgetList = [
//       Column(
//         children: [
//           SwitchListTile(
//             value: false,
//             title: const Text('Notifications[Not Available]'),
//             subtitle: Text(
//               'Receive notifications even when the app is closed',
//               style: TextStyle(color: Theme.of(context).colorScheme.primary),
//             ),
//             isThreeLine: true,
//             onChanged: null,
//           ),
//           ListTile(
//             title: Text(
//               'Sign Out',
//               style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                     color: Colors.red,
//                   ),
//             ),
//             onTap: () async {
//               while (Navigator.of(context).canPop()) {
//                 Navigator.of(context).pop();
//               }
//               settingsClass.clearSettings();
//               auth.signOut();
//             },
//           ),
//         ],
//       ),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: shaderText(context, title: 'Settings'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             if (currentUser.email != null) const CurrentUserTile(),
//             const Divider().animate().scaleX(
//                 duration: duration * 2,
//                 curve: Curves.decelerate,
//                 begin: 0,
//                 end: 1),
//             Section(
//               title: "App Settings",
//               children: widgetList.animate().fade(duration: duration).slideX(
//                   curve: Curves.decelerate,
//                   begin: 1,
//                   end: 0,
//                   duration: duration),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
