import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/admin_panel/manage_user.dart';

class UserList extends StatefulWidget {
  const UserList({super.key, required this.userType});
  final String userType;

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String userType = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.userType) {
      case 'Manage Students':
        userType = 'student';
        break;
      case 'Manage Wardens':
        userType = 'warden';
        break;
      case 'Manage Attenders':
        userType = 'attender';
        break;
      case 'Manage Admins':
        userType = 'admin';
        break;
      default:
        userType = 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${widget.userType.substring(7)}'),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimateIcon(
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.loading1,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const Text('Loading...')
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData && snapshot.error != null) {
            return Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimateIcon(
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.error,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const Text('No data available')
                  ],
                ),
              ),
            );
          }

          return userTile(snapshot.data!);
        },
        future: fetchSpecificUsers(userType),
      ),
    );
  }

  Widget userTile(List<UserData> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ManageUser(
                      user: list[index],
                      edit: true,
                    )));
          },
          child: ListTile(
            shape: const CircleBorder(),
            title: Text(list[index].name ?? list[index].email!),
            subtitle: Text(list[index].readonly.type == 'student'
                ? list[index].email!.substring(0, 9).toUpperCase()
                : list[index].email!),
            trailing:
                userType == 'other' && list[index].readonly.type != 'other'
                    ? Text('UserType: ${list[index].readonly.type}')
                    : null,
          ),
        );
      },
    );
  }
}
