// import 'package:flutter/material.dart';
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import 'package:hustle_stay/providers/roommates.dart';

// class RoommateForm extends ConsumerStatefulWidget {
//   RoommateForm({super.key, required this.currentRoomNumber});
//   int currentRoomNumber;

//   @override
//   ConsumerState<RoommateForm> createState() => _RoommateFormState();
// }

// class _RoommateFormState extends ConsumerState<RoommateForm> {
//   String roommateName = "";
//   String roommateEmail = "";
//   String roomName = "";
//   var numRoommates = 0;
//   bool isRunning = false;
//   int currentRoommate = 0;
//   Map<String, String> roomMates = {};
//   final _formKey = GlobalKey<FormState>();
//   void _saveRoommate() {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//     _formKey.currentState?.save();
//     setState(() {
//       roomMates[roommateEmail] = roommateName;
//       roommateEmail = "";
//       roommateName = "";
//       currentRoommate += 1;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           Text(
//             "Room ${widget.currentRoomNumber + 1}",
//             style: Theme.of(context).textTheme.bodySmall,
//           ),
//           SizedBox(
//             height: 5,
//           ),
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: "Enter Room name",
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return "Enter room name";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               roomName = value;
//             // },
//           ),
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: "Number of Roommates",
//             ),
//             onChanged: (value) {
//               setState(() {
//                 numRoommates = int.parse(value);
//               });
//             },
//           ),
//           for (int i = 0; i < numRoommates; i++)
//             Container(
//               child: Row(
//                 children: [
//                   Column(
//                     children: [
//                       Text("Roommate ${i + 1}"),
//                       SizedBox(
//                         height: 3,
//                       ),
//                       TextFormField(
//                         enabled: i == currentRoommate,
//                         decoration: InputDecoration(
//                           labelText: "Name",
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return "Enter roommate name";
//                           }
//                           return null;
//                         },
//                         onChanged: (value) {
//                           setState(() {
//                             roommateName = value;
//                           });
//                         },
//                       ),
//                       TextFormField(
//                           enabled: i == currentRoommate,
//                           decoration: InputDecoration(
//                             labelText: "Email",
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return "Enter roommate email";
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             setState(() {
//                               roommateEmail = value;
//                             });
//                           }),
//                     ],
//                   ),
//                   if (currentRoommate == i)
//                     isRunning
//                         ? CircularProgressIndicator()
//                         : TextButton.icon(
//                             onPressed: () {
//                               setState(() {
//                                 isRunning = true;
//                               });
//                               _saveRoommate();
//                             },
//                             icon: Icon(Icons.add_circle),
//                             label: Text("Add Roommate")),
//                 ],
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }
