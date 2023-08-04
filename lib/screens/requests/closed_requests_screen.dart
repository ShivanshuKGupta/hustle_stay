import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/widgets/other/scroll_builder.dart';

// ignore: must_be_immutable
class ClosedRequestsScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const ClosedRequestsScreen({super.key, this.scrollController});

  @override
  State<ClosedRequestsScreen> createState() => _ClosedRequestsScreenState();
}

class _ClosedRequestsScreenState extends State<ClosedRequestsScreen> {
  Map<String, DocumentSnapshot> savePoint = {};
  bool showOthers = false;
  final List<String> types = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('Closed Requests')),
        actions: [
          if (currentUser.readonly.type != 'student')
            FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: showOthers,
                    onChanged: (value) {
                      setState(() {
                        showOthers = value;
                        savePoint.clear();
                      });
                    },
                  ),
                  Text(
                    '${showOthers ? 'Hide' : "Show"} Other Requests',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ScrollBuilder(
          key: UniqueKey(),
          automaticLoading: true,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          scrollController: widget.scrollController,
          loader: (ctx, start, interval) async {
            if (types.isEmpty &&
                savePoint.isEmpty &&
                currentUser.readonly.type != 'student') {
              final response = await firestore
                  .collection('requests')
                  .where('isType', isEqualTo: true)
                  .get();
              for (var doc in response.docs) {
                Request.allApprovers[doc.id] =
                    (doc.data()['approvers'] as List<dynamic>)
                        .map((e) => e.toString())
                        .toList();
                if (Request.allApprovers[doc.id]!.contains(currentUser.email)) {
                  types.add(doc.id);
                }
              }
            }
            final List<Request> requests = await fetchClosedRequests(
              limit: interval,
              savePoint: savePoint,
              showOthers: showOthers,
              types: types,
            );
            // debugPrint("Last doc: ${savePoint['lastDoc']!.id}");
            return requests.map(
              (request) {
                // debugPrint(request.id.toString());
                return request.widget(context);
              },
            );
          },
        ),
      ),
    );
  }
}

/// If given types then it fetches approvers requests
/// or else student's requests
Future<List<Request>> fetchClosedRequests({
  Source? src,
  List<String>? types,
  int? limit,
  bool showOthers = false,
  Map<String, DocumentSnapshot>? savePoint,
}) async {
  Query<Map<String, dynamic>> query = firestore.collection('requests');
  query = query.where('closedAt', isGreaterThan: 0);

  if (types == null || types.isEmpty) {
    query = query.where('requestingUserEmail', isEqualTo: currentUser.email);
  } else {
    if (showOthers) {
      query = query.where('approvers', arrayContains: currentUser.email);
    } else {
      query = query.where('type', whereIn: types);
    }
  }

  query = query.orderBy('closedAt', descending: true);
  if (savePoint != null && savePoint['lastDoc'] != null) {
    query = query.startAfterDocument(savePoint['lastDoc']!);
  }
  if (limit != null) {
    query = query.limit(limit);
  }

  final response =
      await query.get(src == null ? null : GetOptions(source: src));
  if (response.docs.isNotEmpty && savePoint != null) {
    savePoint['lastDoc'] = response.docs.last;
  }
  List<Request> requests = response.docs.map((doc) {
    return decodeToRequest(doc.data());
  }).toList();
  requests.sort((a, b) {
    return a.closedAt > b.closedAt ? 0 : 1;
  });
  return requests;
}
