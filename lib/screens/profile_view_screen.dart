import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';

import '../tools.dart';

class ProfileViewScreen extends StatefulWidget {
  ProfileViewScreen({super.key, required this.email});
  String email;

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder(
            future: fetchUserData(widget.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: circularProgressIndicator(
                    height: null,
                    width: null,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: Text('No records exist'),
                );
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundImage: null,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const Divider(),
                      Text("Name: ${snapshot.data!.name}"),
                      Text("${snapshot.data!.phoneNumber}"),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
