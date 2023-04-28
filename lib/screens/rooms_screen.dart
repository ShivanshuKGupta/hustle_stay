import 'package:flutter/material.dart';

class RoomsScreen extends StatelessWidget {
  final String hostelName;
  const RoomsScreen({super.key, required this.hostelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a room'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return _RoomAdder();
                  });
            },
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}

List<TextEditingController> _roomIDs = [];

class _RoomAdder extends StatefulWidget {
  const _RoomAdder({super.key});

  @override
  State<_RoomAdder> createState() => _RoomAdderState();
}

class _RoomAdderState extends State<_RoomAdder> {
  TextEditingController _lengthTxtField = TextEditingController();
  int length = 0;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _lengthTxtField,
                    decoration: const InputDecoration(
                      label: Text("Total Rooms"),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        final value = _lengthTxtField.text;
                        if (value.isEmpty) return;
                        int newLen = 0;
                        try {
                          newLen = int.parse(value);
                        } catch (e) {
                          return;
                        }
                        if (newLen >= 1) {
                          setState(() {
                            length = newLen;
                            _roomIDs = [
                              for (int i = 0; i < length; ++i)
                                TextEditingController()
                            ];
                          });
                        }
                      },
                      child: const Text('List Rooms')),
                )
              ],
            ),
            for (int i = 0; i < length; ++i)
              ListTile(
                title: TextField(
                  controller: _roomIDs[i],
                  decoration: const InputDecoration(
                    label: Text("Room ID"),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
