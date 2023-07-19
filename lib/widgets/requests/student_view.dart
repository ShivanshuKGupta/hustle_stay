import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/requests/van/van_request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/post_request_options.dart';

class StudentView extends StatefulWidget {
  const StudentView({super.key});

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
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
      if (type == 'VanRequest') {
        return VanRequest(requestingUserEmail: data['requestingUserEmail'])
          ..load(data);
      }
      throw "No such type exists: '$type'";
    }).toList();
    for (var e in requestTypes) {
      fetchApprovers(e, src: src);
    }
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        await getStudentRequests();
        setState(() {});
      },
      child: ListView(
        children: [
          CacheBuilder(
            builder: (ctx, data) {
              final children = data.map((e) => e.widget(context)).toList();
              if (children.isNotEmpty) {
                children.insert(
                  0,
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 15),
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
            provider: getStudentRequests,
          ),
          if (currentUser.readonly.type == 'student' ||
              true) // TODO: remove short circuiting
            const PoptRequestOptions(),
        ],
      ),
    );
  }
}
