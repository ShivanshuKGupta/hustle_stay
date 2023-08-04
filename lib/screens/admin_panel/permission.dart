import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user/permissions.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';
import 'package:hustle_stay/widgets/other/select_many.dart';

// ignore: must_be_immutable
class PermissionsPage extends StatelessWidget {
  final String email;
  final String type;
  const PermissionsPage({super.key, required this.email, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type.toPascalCase()),
      ),
      body: UserBuilder(
        email: email,
        builder: (ctx, user) {
          return PermissionWidget(user: user, type: type);
        },
      ),
    );
  }
}

class PermissionWidget extends StatelessWidget {
  final UserData user;
  final String type;
  final bool showSaveButton;
  final bool expanded;
  final void Function(CRUD crud)? onChange;
  const PermissionWidget({
    super.key,
    required this.user,
    required this.type,
    this.showSaveButton = true,
    this.expanded = true,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SelectMany(
          title: type.toPascalCase(),
          expanded: expanded,
          allOptions: CRUD.values,
          selectedOptions: CRUD.values
              .where((e) => user.readonly.permissions[type]![e] == true)
              .toSet(),
          onChange: (chosenOptions) {
            for (var element in CRUD.values) {
              user.readonly.permissions[type]![element] =
                  chosenOptions.contains(element);
            }
            if (onChange != null) {
              onChange!(user.readonly.permissions[type]!);
            }
          },
        ),
        if (showSaveButton)
          LoadingElevatedButton(
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save'),
            onPressed: () async => await updateUserData(user),
          ),
      ],
    );
  }
}

// class PermissionWidget extends StatefulWidget {
//   const PermissionWidget({super.key, required this.email, required this.type});
//   final String email;
//   final String type;

//   @override
//   State<PermissionWidget> createState() => _PermissionWidgetState();
// }

// class _PermissionWidgetState extends State<PermissionWidget> {
//   List<String> operation = ['Create', 'Update', 'Read', 'Delete'];
//   Map<String, bool> dData = {
//     'Create': false,
//     'Update': false,
//     'Read': false,
//     'Delete': false
//   };
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getPermissionData(widget.email);
//   }

//   Map<String, dynamic> data = {};
//   bool isReady = false;
//   Future<void> getPermissionData(String email) async {
//     final ref =
//         await FirebaseFirestore.instance.collection('users').doc(email).get();
//     if (ref.data()!['permissions'] == null) {
//       setState(() {
//         data = {
//           'Attendance': dData,
//           'Categories': dData,
//           'Users': dData,
//           'Approvers': dData
//         };
//         for (int i = 0; i < operation.length; i++) {
//           permissionData.value[operation[i]] = false;
//         }
//         isReady = true;
//       });
//     } else {
//       setState(() {
//         data = ref.data()!['permissions'];
//         permissionData.value = ref.data()!['permissions'][widget.type] ?? dData;
//         isReady = true;
//       });
//       // print('hi');

//       // print(data);
//       // print(permissionData.value);
//     }
//   }

//   ValueNotifier<Map<String, dynamic>> permissionData = ValueNotifier({});

//   @override
//   Widget build(BuildContext context) {
//     double widthScreen = MediaQuery.of(context).size.width;
//     final brightness = Theme.of(context).brightness;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.type} Permissions'),
//       ),
//       body: isReady
//           ? ListView.builder(
//               itemBuilder: (context, index) {
//                 print(permissionData);
//                 return index == operation.length
//                     ? ValueListenableBuilder(
//                         valueListenable: permissionData,
//                         builder: (context, value, child) => ElevatedButton.icon(
//                             onPressed: () async {
//                               setState(() {
//                                 data[widget.type] = permissionData.value;
//                               });
//                               final resp =
//                                   await modifyPermissions(data, widget.email);
//                               if (resp) {
//                                 Navigator.of(context).pop();
//                               } else if (mounted) {
//                                 ScaffoldMessenger.of(context).clearSnackBars();
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text(
//                                             'Operation failed.Try again')));
//                               }
//                             },
//                             icon: const Icon(Icons.login),
//                             label: const Text('Submit')),
//                       )
//                     : GestureDetector(
//                         onTap: () {},
//                         child: Padding(
//                           padding: const EdgeInsets.all(2.0),
//                           child: Container(
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16.0),
//                                   border: Border.all(
//                                       color: brightness == Brightness.light
//                                           ? Colors.black
//                                           : Colors.white)),
//                               child: ListTile(
//                                 title: Text(operation[index]),
//                                 contentPadding:
//                                     EdgeInsets.all(widthScreen * 0.002),
//                                 trailing: StatusIcon(
//                                   email: widget.email,
//                                   operation: operation[index],
//                                   permissionData: permissionData,
//                                 ),
//                               )),
//                         ),
//                       );
//               },
//               itemCount: operation.length + 1,
//             )
//           : Container(),
//     );
//   }
// }

// class StatusIcon extends StatefulWidget {
//   StatusIcon({
//     super.key,
//     required this.email,
//     required this.operation,
//     required this.permissionData,
//   });
//   final String email;
//   final String operation;
//   ValueNotifier<Map<String, dynamic>> permissionData;

//   @override
//   State<StatusIcon> createState() => _StatusIconState();
// }

// class _StatusIconState extends State<StatusIcon> {
//   bool isAllowed = false;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (widget.permissionData.value[widget.operation] == true) {
//       isAllowed = true;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//         onPressed: () {
//           print(widget.permissionData.value);
//           final resp =
//               widget.permissionData.value[widget.operation] ?? isAllowed;
//           widget.permissionData.value[widget.operation] = !resp;
//           setState(() {
//             isAllowed = !isAllowed;
//           });
//         },
//         icon: isAllowed
//             ? const Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.green,
//               )
//             : const Icon(
//                 Icons.cancel_outlined,
//                 color: Colors.red,
//               ));
//   }
// }
