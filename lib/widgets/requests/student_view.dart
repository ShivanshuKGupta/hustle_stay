import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/post_request_options.dart';

class RequestsList extends StatefulWidget {
  const RequestsList({super.key});

  @override
  State<RequestsList> createState() => _RequestsListState();
}

class _RequestsListState extends State<RequestsList> {
  /// It returns requests and fetches required approvers as well
  Future<List<Request>> getStudentRequests({Source? src}) async {
    final collection = firestore.collection('requests');
    final response = await collection
        .where('requestingUserEmail', isEqualTo: currentUser.email)
        .where(
          'expiryDate',
          isGreaterThan: DateTime.now().millisecondsSinceEpoch,
        )
        .get(src == null ? null : GetOptions(source: src));
    final docs = response.docs;
    Set<String> requestTypes = {};
    List<Request> requests = docs.map((doc) {
      final data = doc.data();
      final type = data['type'];
      requestTypes.add(type);
      return decodeToRequest(data);
    }).toList();
    for (var e in requestTypes) {
      fetchApproversOfRequestType(e, src: src);
    }
    return requests;
  }

  /// It returns requests and fetches required approvers as well
  Future<List<Request>> getApproverRequests({Source? src}) async {
    // Change this to fetch all requests where he is the approver
    // if he fetched a non integer id then those are definitely types
    // then fetch all request with those types

    final collection = firestore.collection('requests');
    var response = await collection
        .where('approvers', arrayContains: currentUser.email)
        .where('status', isEqualTo: RequestStatus.pending.index)
        .get(src == null ? null : GetOptions(source: src));
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = response.docs;
    final List<Request> requests = [];
    final List<String> types = [];
    for (final doc in docs) {
      if (int.tryParse(doc.id) == null) {
        types.add(doc.id);
      } else {
        requests.add(decodeToRequest(doc.data()));
      }
    }
    if (types.isNotEmpty) {
      response = await collection
          .where('type', whereIn: types)
          .where('status', isEqualTo: RequestStatus.pending.index)
          .get(src == null ? null : GetOptions(source: src));
      docs = response.docs;
      requests.addAll(docs.map((doc) {
        final data = doc.data();
        return decodeToRequest(data);
      }));
    }
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        try {
          if (currentUser.readonly.type == 'student') {
            await getStudentRequests();
          } else {
            await getApproverRequests();
          }
        } catch (e) {
          showMsg(context, e.toString());
        }
        setState(() {});
      },
      child: ListView(
        children: [
          if (currentUser.readonly.type == 'student' ||
              currentUser.email == 'code_soc@students.iiitr.ac.in')
            const PostRequestOptions(),
          CacheBuilder(
            loadingWidget: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: circularProgressIndicator(),
              ),
            ),
            builder: (ctx, data) {
              data.sort(
                (a, b) {
                  return a.id < b.id ? 1 : 0;
                },
              );
              final children = data.map((e) => e.widget(context)).toList();
              if (children.isEmpty && currentUser.readonly.type != 'student') {
                return SizedBox(
                  height: mediaQuery.size.height -
                      mediaQuery.viewInsets.top -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom -
                      mediaQuery.viewInsets.bottom -
                      150,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimateIcon(
                          onTap: () {},
                          iconType: IconType.continueAnimation,
                          animateIcon: AnimateIcons.cool,
                        ),
                        Text(
                          'No requests are pending',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (children.isNotEmpty) {
                children.insert(
                  0,
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, bottom: 5),
                    child: shaderText(
                      context,
                      title:
                          '${currentUser.readonly.type == 'student' ? 'Your' : 'Pending'} Requests',
                      style: theme.textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return ListView.separated(
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: children.length,
                itemBuilder: (ctx, index) {
                  return children[index];
                },
              );
            },
            provider: currentUser.readonly.type == 'student'
                ? getStudentRequests
                : getApproverRequests,
          ),
        ],
      ),
    );
  }
}
