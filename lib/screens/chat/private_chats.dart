import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/tools.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chats'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigatorPush(
            context,
            Scaffold(
              appBar: AppBar(
                title: const Text('Who to chat with?'),
              ),
              body: UsersBuilder(
                builder: (ctx, users) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        onTap: () {
                          final String id =
                              (currentUser.email!.compareTo(user.email!) < 0)
                                  ? "${currentUser.email}-${user.email}"
                                  : "${user.email}-${currentUser.email}";
                          firestore.collection('chats').doc(id).set({
                            'recipients': [currentUser.email, user.email],
                          });
                          showChat(context, id: id, emails: [user.email!]);
                        },
                        title: Text(user.name ?? user.email!),
                        leading: user.imgUrl == null
                            ? null
                            : CachedNetworkImage(imageUrl: user.imgUrl!),
                      );
                    },
                    itemCount: users.length,
                  );
                },
              ),
            ),
          );
        },
        child: const Icon(
          Icons.chat_rounded,
        ),
      ),
      body: CacheBuilder(
        builder: (ctx, docs) {
          return ListView.builder(
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final receipeints = (data['recipients'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
              String? title = data['title'];
              String person2 = "";
              if (title == null) {
                if (receipeints.length == 2) {
                  person2 = receipeints.firstWhere(
                    (element) => element != currentUser.email,
                    orElse: () => currentUser.email!,
                  );
                } else {
                  title = doc.id;
                }
              }
              return ListTile(
                title: CacheBuilder(
                  src: Source.cache,
                  builder: (ctx, name) => Text(name),
                  provider: ({src}) async {
                    if (title != null) return title;
                    final user = (await fetchUserData(
                      person2,
                      readonly: true,
                      src: src,
                    ));
                    return user.name ?? user.email!;
                  },
                ),
                subtitle: Text(
                  data['recipients'].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  maxLines: 1,
                ),
                onTap: () => showChat(
                  context,
                  id: doc.id,
                  emails: receipeints,
                ),
              );
            },
            itemCount: docs.length,
          );
        },
        provider: ({Source? src}) async {
          return (await firestore
                  .collection('chats')
                  .where('recipients', arrayContains: currentUser.email!)
                  .get(src == null ? null : GetOptions(source: src)))
              .docs;
        },
      ),
    );
  }
}
