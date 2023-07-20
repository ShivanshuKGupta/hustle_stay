import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/requests/vehicle/vehicle_request.dart';
import 'package:hustle_stay/models/user.dart';
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
      if (type == 'Vehicle') {
        return VehicleRequest(requestingUserEmail: data['requestingUserEmail'])
          ..load(data);
      }
      throw "No such type exists: '$type'";
    }).toList();
    for (var e in requestTypes) {
      fetchApprovers(e, src: src);
    }
    return requests;
  }

  /// It returns requests and fetches required approvers as well
  Future<List<Request>> getApproverRequests({Source? src}) async {
    for (var e in Request.allTypes) {
      await fetchApprovers(e, src: src);
    }
    final List<String> myRequestTypes = [];
    for (var entry in Request.allApprovers.entries) {
      if (entry.value.contains(currentUser.email)) {
        myRequestTypes.add(entry.key);
      }
    }
    if (myRequestTypes.isEmpty) {
      // This person is neither a approver nor a student
      // then assuming that this person is a student
      return await getStudentRequests(src: src);
    }
    final collection = firestore.collection('requests');
    final response = await collection
        .where('type', whereIn: myRequestTypes)
        .where('status', isEqualTo: RequestStatus.pending.index)
        .get(src == null ? null : GetOptions(source: src));
    final docs = response.docs;
    List<Request> requests = docs.map((doc) {
      final data = doc.data();
      final type = data['type'];
      if (type == 'Vehicle') {
        return VehicleRequest(requestingUserEmail: data['requestingUserEmail'])
          ..load(data);
      }
      throw "No such type exists: '$type'";
    }).toList();
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        if (currentUser.readonly.type == 'student') {
          await getStudentRequests();
        } else {
          await getApproverRequests();
        }
        setState(() {});
      },
      child: ListView(
        children: [
          if (currentUser.readonly.type == 'student')
            const PoptRequestOptions(),
          CacheBuilder(
            builder: (ctx, data) {
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
            provider: currentUser.readonly.type == 'student'
                ? getStudentRequests
                : getApproverRequests,
          ),
        ],
      ),
    );
  }
}
