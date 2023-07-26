import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chats'),
      ),
      body: CacheBuilder(builder: (ctx, docs) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final receipeints = (data['recipients'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            String? title = data['title'];
            if (title == null) {
              if (receipeints.length == 2) {
                title = receipeints
                    .firstWhere((element) => element != currentUser.email);
              } else {
                title = doc.id;
              }
            }
            return ListTile(
              title: Text(title),
              subtitle: Text(
                data['recipients'].toString(),
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
      }, provider: ({Source? src}) async {
        return (await firestore
                .collection('chats')
                .where('recipients', arrayContains: currentUser.email!)
                .get(src == null ? null : GetOptions(source: src)))
            .docs;
      }),
    );
  }
}
