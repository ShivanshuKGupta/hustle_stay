import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/admin_panel/user_list.dart';
import 'package:hustle_stay/screens/auth/edit_profile_screen.dart';
import '../../models/common/operation.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List<Operations> catList = [
    Operations(
        cardColor: const Color.fromARGB(255, 98, 0, 238),
        operationName: 'Manage Students',
        icon: const Icon(Icons.person)),
    Operations(
        cardColor: const Color.fromARGB(255, 239, 108, 0),
        operationName: 'Manage Wardens',
        icon: const Icon(Icons.person_4_rounded)),
    Operations(
        cardColor: const Color.fromARGB(255, 238, 0, 0),
        operationName: 'Manage Attenders',
        icon: const Icon(Icons.person_pin)),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 69),
        operationName: 'Manage Admins',
        icon: const Icon(Icons.admin_panel_settings_rounded)),
    Operations(
        cardColor: const Color.fromARGB(255, 146, 0, 146),
        operationName: 'Manage Other Users',
        icon: const Icon(Icons.all_inbox)),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 110),
        operationName: 'Add new User',
        icon: const Icon(Icons.person_add_outlined)),
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = (screenWidth) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users & Permissions'),
      ),
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final Color cardColor = catList[index].cardColor!;

            final LinearGradient gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: brightness == Brightness.light
                  ? [
                      cardColor.withOpacity(0.2),
                      Colors.white,
                    ]
                  : [
                      cardColor.withOpacity(0.7),
                      Colors.black,
                    ],
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 8, 8),
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            catList[index].operationName == 'Add new User'
                                ? EditProfile()
                                : UserList(
                                    userType: catList[index].operationName)));
                  },
                  child: Container(
                    width: gridWidth,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient:
                          brightness == Brightness.light ? null : gradient,
                      color: brightness == Brightness.light
                          ? cardColor.withOpacity(0.2)
                          : null,
                      boxShadow: brightness == Brightness.light
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Icon(
                            catList[index].icon!.icon,
                            size: screenWidth * 0.3,
                          ),
                        ),
                        Divider(
                          color: brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          catList[index].operationName,
                          overflow: TextOverflow.clip,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: brightness == Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                        ),
                        Divider(
                          color: brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ],
                    ),
                  )),
            );
          },
          itemCount: catList.length,
        ),
      ),
    );
  }
}
