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
  bool showDeniedRequests = false;
  final List<String> types = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('Closed Requests')),
        actions: [
          FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: showDeniedRequests,
                  onChanged: (value) {
                    setState(() {
                      showDeniedRequests = value;
                      savePoint.clear();
                    });
                  },
                ),
                Text(
                  '${showDeniedRequests ? 'Denied' : "Approved"} Requests',
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
                currentUser.type != 'student') {
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
            final List<Request> requests = await fetchRequests(
              limit: interval,
              savePoint: savePoint,
              status: showDeniedRequests
                  ? RequestStatus.denied
                  : RequestStatus.approved,
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
