import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/widgets/scroll_builder.dart/scroll_builder.dart';

class ClosedRequestsScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const ClosedRequestsScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolved Complaints'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ScrollBuilder(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          scrollController: scrollController,
          interval: 20,
          loader: (context, start, interval) async {
            final List<Request> requests = await fetchRequests(
              limit: interval,
              // lastDoc: start,
            );
            return requests.map(
              (request) => request.widget(context),
            );
          },
        ),
      ),
    );
  }
}

Future<List<Request>> fetchRequests(
    {Source? src,
    List<String>? approvers,
    DocumentSnapshot? lastDoc,
    int? limit}) async {
  Query<Map<String, dynamic>> collection = firestore.collection('requests');

  if (approvers == null) {
    // Student side
    collection = collection.where(
      'requestingUserEmail',
      isEqualTo: currentUser.email,
    );
    if (limit != null) {
      collection = collection.limit(limit);
    }
    if (lastDoc != null) {
      collection = collection.startAfterDocument(lastDoc);
    }
  }

  final response =
      await collection.get(src == null ? null : GetOptions(source: src));
  List<Request> requests = response.docs.map((doc) {
    return decodeToRequest(doc.data());
  }).toList();
  requests.sort((a, b) {
    return a.id > b.id ? 0 : 1;
  });
  return requests;
}
