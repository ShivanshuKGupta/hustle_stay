import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hustle_stay/models/hostels.dart';
// import 'package:hustle_stay/screens/addHostel.dart';

import '../models/hostels.dart';
import '../tools.dart';
// import 'package:hustle_stay/models/user.dart';

final _firebase = FirebaseAuth.instance;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder(
        future: fetchHostels(),
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
              child: Text('No Hostel added yet!'),
            );
          }
          print(snapshot.data);

          return ListView.builder(
            itemBuilder: (context, index) {
              Hostels hostel = snapshot.data![index];
              String? imageUrl = hostel.imageUrl;
              return Card(
                elevation: 6,
                child: Column(
                  children: [
                    Image.network(
                      imageUrl,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          // Image is fully loaded
                          return child;
                        }
                        return Container(
                          width: double.infinity,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Text('Failed to load image');
                      },
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    ListTile(
                      title: Text(hostel.hostelName),
                      subtitle: Text(hostel.hostelType),
                    )
                  ],
                ),
              );
            },
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
