import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';

class UserTile extends StatelessWidget {
  final String email;
  final void Function(UserData user) removeUser;
  const UserTile({
    super.key,
    required this.email,
    required this.removeUser,
  });

  @override
  Widget build(BuildContext context) {
    UserData user = UserData(email: email);
    TextStyle style = Theme.of(context).textTheme.bodySmall!;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: fetchUserData(email, src: null),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return FutureBuilder(
                    future: fetchUserData(email, src: Source.cache),
                    builder: (ctx, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          email,
                          style: style,
                        );
                      }
                      user = snapshot.data!;
                      return Text(
                        user.name ?? email,
                        style: style,
                      );
                    },
                  );
                }
                user = snapshot.data!;
                return Text(
                  user.name ?? email,
                  style: style,
                );
              },
            ),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              onPressed: () => removeUser(user),
              icon: const Icon(
                Icons.close_rounded,
              ),
            )
          ],
        ),
      ),
    );
  }
}
