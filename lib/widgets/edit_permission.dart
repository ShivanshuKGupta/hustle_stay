import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/admin_panel/permission.dart';

import '../models/common/operation.dart';

class EditPermissions extends StatefulWidget {
  const EditPermissions({super.key, required this.email});
  final String email;

  @override
  State<EditPermissions> createState() => _EditPermissionsState();
}

class _EditPermissionsState extends State<EditPermissions> {
  List<Operations> catList = [
    Operations(
        cardColor: const Color.fromARGB(255, 98, 0, 238),
        operationName: 'Attendance',
        icon: const Icon(Icons.calendar_month)),
    Operations(
        cardColor: const Color.fromARGB(255, 239, 108, 0),
        operationName: 'Categories',
        icon: const Icon(Icons.category)),
    Operations(
        cardColor: const Color.fromARGB(255, 238, 0, 0),
        operationName: 'Users',
        icon: const Icon(Icons.person)),
    Operations(
        cardColor: const Color.fromARGB(255, 0, 146, 69),
        operationName: 'Approvers',
        icon: const Icon(Icons.person_2_outlined)),
  ];
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = (screenWidth) / 2;
    return SafeArea(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final Color cardColor = catList[index].cardColor;

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
                      builder: (_) => Permission(
                          email: widget.email,
                          type: catList[index].operationName)));
                },
                child: Container(
                  width: gridWidth,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: brightness == Brightness.light ? null : gradient,
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
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
    );
  }
}
