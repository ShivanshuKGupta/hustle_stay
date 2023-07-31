import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/auth/edit_profile_screen.dart';
import 'package:hustle_stay/screens/chat/image_preview.dart';
import 'package:hustle_stay/tools.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePreview extends StatelessWidget {
  final UserData user;
  final bool showChatButton, showCallButton, showMailButton;
  const ProfilePreview({
    super.key,
    required this.user,
    this.showChatButton = true,
    this.showCallButton = true,
    this.showMailButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (user.imgUrl != null) {
              navigatorPush(
                context,
                ImagePreview(
                  image: Hero(
                    tag: 'profile-image',
                    child: CachedNetworkImage(imageUrl: user.imgUrl!),
                  ),
                ),
              );
            }
          },
          child: Hero(
            tag: 'profile-image',
            child: CircleAvatar(
              backgroundImage: user.imgUrl == null
                  ? null
                  : CachedNetworkImageProvider(user.imgUrl!),
              radius: 50,
              child: user.imgUrl != null
                  ? null
                  : const Icon(
                      Icons.person_rounded,
                      size: 50,
                    ),
            ),
          ),
        ),
        InkWell(
          onTap: (user.email == currentUser.email ||
                  currentUser.readonly.permissions.users.update == true)
              ? () {
                  navigatorPush(context, EditProfile(user: user));
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                shaderText(
                  context,
                  title: user.name ?? user.email!,
                  colors: [
                    Colors.deepPurpleAccent,
                    Colors.indigo,
                    Colors.blue,
                  ],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  user.email!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            if (showChatButton)
              IconButton(
                onPressed: () {
                  final String id =
                      (currentUser.email!.compareTo(user.email!) < 0)
                          ? "${currentUser.email}-${user.email}"
                          : "${user.email}-${currentUser.email}";
                  firestore.collection('chats').doc(id).set({
                    'recipients': [currentUser.email, user.email],
                  });
                  showChat(context, id: id, emails: [user.email!]);
                },
                icon: const Icon(Icons.chat_rounded),
              ),
            if (showCallButton)
              if (user.phoneNumber != null)
                IconButton(
                  onPressed: () {
                    launchUrl(Uri.parse('tel:${user.phoneNumber}'));
                  },
                  icon: const Icon(Icons.call_rounded),
                ),
            if (showMailButton)
              IconButton(
                onPressed: () {
                  launchUrl(Uri.parse('mailto:${user.email}'));
                },
                icon: const Icon(Icons.mail_rounded),
              ),
          ],
        ),
      ],
    );
  }
}
