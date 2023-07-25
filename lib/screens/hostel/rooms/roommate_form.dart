import 'package:animated_icon/animated_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:hustle_stay/models/hostel/rooms/room.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';

import '../../../models/user.dart';
import '../../../tools.dart';

class RoommateForm extends ConsumerStatefulWidget {
  RoommateForm(
      {super.key,
      required this.capacity,
      required this.hostelName,
      required this.roomName,
      required this.numRoommates});
  String roomName;
  String hostelName;
  int capacity;
  int numRoommates;

  @override
  ConsumerState<RoommateForm> createState() => _RoommateFormState();
}

class _RoommateFormState extends ConsumerState<RoommateForm> {
  final List<GlobalKey<FormState>> _formKeyList = [];
  final storage = FirebaseFirestore.instance;

  int currentRoommateNumber = 0;
  String roommateEmail = "";
  bool isOverflow = false;
  var numOfRoommates = 0;
  bool isRunning = false;
  void addRoommate(int index) async {
    if (_formKeyList[index].currentState!.validate()) {
      _formKeyList[index].currentState!.save();
      try {
        final userCheck =
            await storage.collection('users').doc(roommateEmail).get();
        if (!userCheck.exists) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'No user exists with this email. Create an account to add here.')));
          setState(() {
            isRunning = false;
          });
          return;
        }
        final userLoc =
            await storage.collection('users').doc(roommateEmail).get();
        if (userLoc.data()!.containsKey('hostelName') &&
            userLoc.data()!['hostelName'] != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Hostel is already allocated to $roommateEmail. \n Hostel: ${userLoc['hostelName']} and Room: ${userLoc['roomName']}')));
          setState(() {
            isRunning = false;
          });
          return;
        }
        final loc = storage.collection('hostels').doc('hostelMates');

        await loc.collection('Roommates').doc(roommateEmail).set({
          'email': roommateEmail,
          'hostelName': widget.hostelName,
          'roomName': widget.roomName
        });
        await storage.collection('users').doc(roommateEmail).set(
            {'hostelName': widget.hostelName, 'roomName': widget.roomName},
            SetOptions(merge: true)).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error occured in updation')));
        });
        await storage
            .collection('hostels')
            .doc(widget.hostelName)
            .collection('Rooms')
            .doc(widget.roomName)
            .update({'numRoommates': FieldValue.increment(1)});
        if (currentRoommateNumber < numOfRoommates - 1) {
          setState(() {
            currentRoommateNumber += 1;
            roommateEmail = "";
            isRunning = false;
          });

          return;
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => RoomsScreen(hostelName: widget.hostelName),
        ));
      } catch (e) {}
    }
    setState(() {
      isRunning = false;
    });
  }

  ValueNotifier<List<String>> emailsToAdd = ValueNotifier([]);
  bool selectRoommate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Add Roommate"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  selectRoommate = !selectRoommate;
                });
              },
              icon: selectRoommate
                  ? Icon(Icons.edit_note_rounded)
                  : Icon(Icons.filter_list_sharp)),
          if (selectRoommate)
            IconButton(
                onPressed: () async {
                  if (emailsToAdd.value.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select user first!')));
                    return;
                  }
                  final resp = await addRommates(
                      emailsToAdd.value, widget.hostelName, widget.roomName);
                  if (resp) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          RoomsScreen(hostelName: widget.hostelName),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Operation Failed. Someone Else might have updated the records at the same time. Kindly refresh and try again.')));
                  }
                  setState(() {});
                },
                icon: Icon(Icons.add_circle))
        ],
      ),
      body: selectRoommate
          ? FutureBuilder(
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
                if (!snapshot.hasData || snapshot.error != null) {
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

                return ListOptionUsers(
                  list: snapshot.data!,
                  emailsToAdd: emailsToAdd,
                  capacity: widget.capacity,
                  numRoommates: widget.numRoommates,
                );
              },
              future: fetchNoHostelUsers(),
            )
          : SingleChildScrollView(
              child: Container(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    // Text("hi"),
                    TextField(
                      decoration: const InputDecoration(
                        label: Text("Number of Roommates to be added"),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value == "") {
                          value = '0';
                        }
                        setState(() {
                          numOfRoommates = value == "" ? 0 : int.parse(value);

                          if (!(widget.capacity >=
                              int.parse(value) + widget.numRoommates)) {
                            numOfRoommates =
                                widget.capacity - widget.numRoommates;
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Capacity Overflow. Only ${widget.capacity - widget.numRoommates}  more roommates can be added.")));
                          }
                          for (int i = 0; i < numOfRoommates; i++) {
                            _formKeyList.add(GlobalKey<FormState>());
                          }
                        });
                      },
                    ),
                    const Divider(),

                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Card(
                            child: Column(
                          children: [
                            Text(
                              "Roommate ${index + 1}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Form(
                              key: _formKeyList[index],
                              child: Column(children: [
                                TextFormField(
                                  enabled: currentRoommateNumber == index,
                                  decoration: const InputDecoration(
                                    labelText: "Email ID",
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Name cannot be empty";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    roommateEmail = value.toLowerCase();
                                  },
                                ),
                                if (currentRoommateNumber == index)
                                  isRunning
                                      ? const CircularProgressIndicator()
                                      : TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              isRunning = true;
                                            });
                                            addRoommate(index);
                                          },
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          label: const Text("Add Roommate"))
                              ]),
                            )
                          ],
                        ));
                      },
                      itemCount:
                          widget.capacity > numOfRoommates + widget.numRoommates
                              ? numOfRoommates
                              : widget.capacity - widget.numRoommates,
                      shrinkWrap: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ListOptionUsers extends StatefulWidget {
  const ListOptionUsers(
      {super.key,
      required this.list,
      required this.emailsToAdd,
      required this.capacity,
      required this.numRoommates});
  final List<UserData> list;
  final ValueNotifier<List<String>> emailsToAdd;
  final int capacity;
  final int numRoommates;

  @override
  State<ListOptionUsers> createState() => ListOptionUsersState();
}

class ListOptionUsersState extends State<ListOptionUsers> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        return UserTileOption(
          emailsToAdd: widget.emailsToAdd,
          user: widget.list[index],
          capacity: widget.capacity,
          numRoommates: widget.numRoommates,
        );
      },
    );
  }
}

class UserTileOption extends StatefulWidget {
  const UserTileOption(
      {super.key,
      required this.emailsToAdd,
      required this.user,
      required this.capacity,
      required this.numRoommates});
  final ValueNotifier<List<String>> emailsToAdd;
  final UserData user;
  final int capacity;
  final int numRoommates;

  @override
  State<UserTileOption> createState() => _UserTileOptionState();
}

class _UserTileOptionState extends State<UserTileOption> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.emailsToAdd,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.black,
                  )),
              onTap: () {
                if (!isSelected &&
                    (widget.capacity > value.length + widget.numRoommates)) {
                  isSelected
                      ? value.remove(widget.user.email)
                      : value.add(widget.user.email!);
                  setState(() {
                    isSelected = !isSelected;
                  });
                } else if (isSelected) {
                  value.remove(widget.user.email);
                  setState(() {
                    isSelected = !isSelected;
                  });
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Capcity Overflow!')));
                }
              },
              tileColor: isSelected ? Colors.green : null,
              title: Text(widget.user.name!),
              subtitle: Text(widget.user.email!),
              leading: CircleAvatar(
                  radius: 50,
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: widget.user.imgUrl == null
                          ? Icon(Icons.person)
                          : CachedNetworkImage(
                              imageUrl: widget.user.imgUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  )),
              trailing:
                  isSelected ? Icon(Icons.check_circle_outline_outlined) : null,
            ),
          ),
        );
      },
    );
  }
}
