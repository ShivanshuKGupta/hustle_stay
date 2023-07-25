import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/user/user.dart';

class Permission extends StatefulWidget {
  const Permission({super.key, required this.email, required this.type});
  final String email;
  final String type;

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  List<String> operation = ['Create', 'Update', 'Read', 'Delete'];
  Map<String, bool> dData = {
    'Create': false,
    'Update': false,
    'Read': false,
    'Delete': false
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissionData(widget.email);
  }

  Map<String, dynamic> data = {};
  bool isReady = false;
  Future<void> getPermissionData(String email) async {
    final ref =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    if (ref.data()!['permissions'] == null) {
      setState(() {
        data = {
          'Attendance': dData,
          'Categories': dData,
          'Users': dData,
          'Approvers': dData
        };
        for (int i = 0; i < operation.length; i++) {
          permissionData.value[operation[i]] = false;
        }
        isReady = true;
      });
    } else {
      setState(() {
        data = ref.data()!['permissions'];
        permissionData.value = ref.data()!['permissions'][widget.type] ?? dData;
        isReady = true;
      });
      // print('hi');

      // print(data);
      // print(permissionData.value);
    }
  }

  ValueNotifier<Map<String, dynamic>> permissionData = ValueNotifier({});

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Permissions'),
      ),
      body: isReady
          ? ListView.builder(
              itemBuilder: (context, index) {
                print(permissionData);
                return index == operation.length
                    ? ValueListenableBuilder(
                        valueListenable: permissionData,
                        builder: (context, value, child) => ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                data[widget.type] = permissionData.value;
                              });
                              final resp =
                                  await modifyPermissions(data, widget.email);
                              if (resp) {
                                Navigator.of(context).pop();
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Operation failed.Try again')));
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Submit')),
                      )
                    : GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                      color: brightness == Brightness.light
                                          ? Colors.black
                                          : Colors.white)),
                              child: ListTile(
                                title: Text(operation[index]),
                                contentPadding:
                                    EdgeInsets.all(widthScreen * 0.002),
                                trailing: StatusIcon(
                                  email: widget.email,
                                  operation: operation[index],
                                  permissionData: permissionData,
                                ),
                              )),
                        ),
                      );
              },
              itemCount: operation.length + 1,
            )
          : Container(),
    );
  }
}

class StatusIcon extends StatefulWidget {
  StatusIcon({
    super.key,
    required this.email,
    required this.operation,
    required this.permissionData,
  });
  final String email;
  final String operation;
  ValueNotifier<Map<String, dynamic>> permissionData;

  @override
  State<StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<StatusIcon> {
  bool isAllowed = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.permissionData.value[widget.operation] == true) {
      isAllowed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          print(widget.permissionData.value);
          final resp =
              widget.permissionData.value[widget.operation] ?? isAllowed;
          widget.permissionData.value[widget.operation] = !resp;
          setState(() {
            isAllowed = !isAllowed;
          });
        },
        icon: isAllowed
            ? const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              )
            : const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              ));
  }
}
