import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/auth/edit_profile_screen.dart';
import 'package:hustle_stay/screens/chat/image_preview.dart';
import 'package:hustle_stay/tools.dart';

class CurrentUserTile extends ConsumerWidget {
  const CurrentUserTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsClass = ref.read(settingsProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: currentUser.imgUrl == null
                ? null
                : () {
                    navigatorPush(
                      context,
                      ImagePreview(
                        image: CachedNetworkImage(
                          imageUrl: currentUser.imgUrl!,
                        ),
                      ),
                    );
                  },
            icon: CircleAvatar(
              backgroundImage: currentUser.imgUrl == null
                  ? null
                  : CachedNetworkImageProvider(currentUser.imgUrl!),
              radius: 30,
              child: currentUser.imgUrl != null
                  ? null
                  : const Icon(
                      Icons.person_rounded,
                      size: 30,
                    ),
            )
                .animate()
                .fade()
                .slideX(begin: -1, end: 0, curve: Curves.decelerate),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchUserData(currentUser.email!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return FutureBuilder(
                      future:
                          fetchUserData(currentUser.email!, src: Source.cache),
                      builder: (ctx, snapshot) {
                        if (snapshot.hasData) {
                          currentUser = snapshot.data!;
                        }
                        return _detailWidget(context, settingsClass)
                            .animate()
                            .fade()
                            .slideX(begin: 1, end: 0, curve: Curves.decelerate);
                      });
                }
                currentUser = snapshot.data!;
                return _detailWidget(context, settingsClass);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailWidget(BuildContext context, settingsClass) {
    return ListTile(
      title: Text(currentUser.name ?? currentUser.email!),
      subtitle: Text(
        currentUser.email!,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: () async {
        // ignore: use_build_context_synchronously
        if (await Navigator.of(context).push<bool?>(
              MaterialPageRoute(
                builder: (ctx) => EditProfile(
                  user: currentUser,
                ),
              ),
            ) ==
            true) {
          settingsClass.notifyListeners();
        }
      },
    );
  }
}
