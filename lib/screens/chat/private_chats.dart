import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/screens/chat/image_preview.dart';
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
                loadingWidget: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      circularProgressIndicator(),
                      const Text('Fetching all Users From Cache'),
                    ],
                  ),
                ),
                provider: fetchUsers,
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
                        leading: GestureDetector(
                          onTap: user.imgUrl == null
                              ? null
                              : () {
                                  navigatorPush(
                                    context,
                                    ImagePreview(
                                      image: Hero(
                                        tag: user.name ?? user.email!,
                                        child: CachedNetworkImage(
                                          imageUrl: user.imgUrl!,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          child: Hero(
                            tag: user.name ?? user.email!,
                            child: CircleAvatar(
                              backgroundImage: user.imgUrl == null
                                  ? null
                                  : CachedNetworkImageProvider(user.imgUrl!),
                              radius: 20,
                              child: user.imgUrl != null
                                  ? null
                                  : const Icon(
                                      Icons.person_rounded,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
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
              return CacheBuilder(
                src: Source.cache,
                loadingWidget: Container(),
                builder: (ctx, user) {
                  return ListTile(
                    title: Text(user.name ?? user.email!),
                    onLongPress: () {
                      if (user.email != null) {
                        showUserPreview(context, user);
                      }
                    },
                    subtitle: Text(
                      data['recipients'].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      maxLines: 1,
                    ),
                    leading: GestureDetector(
                      onTap: user.imgUrl == null
                          ? null
                          : () {
                              navigatorPush(
                                context,
                                ImagePreview(
                                  image: Hero(
                                    tag: user.name ?? user.email!,
                                    child: CachedNetworkImage(
                                      imageUrl: user.imgUrl!,
                                    ),
                                  ),
                                ),
                              );
                            },
                      child: Hero(
                        tag: user.name ?? user.email!,
                        child: CircleAvatar(
                          backgroundImage: user.imgUrl == null
                              ? null
                              : CachedNetworkImageProvider(user.imgUrl!),
                          radius: 20,
                          child: user.imgUrl != null
                              ? null
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                    onTap: () => showChat(
                      context,
                      id: doc.id,
                      emails: receipeints,
                    ),
                  );
                },
                provider: ({src}) async {
                  if (title != null) {
                    return UserData(
                      name: title,
                    );
                  }
                  return await fetchUserData(person2);
                },
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
