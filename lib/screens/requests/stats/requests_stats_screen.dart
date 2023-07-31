import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/firestore_cache_builder.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/requests/stats/request_filter_chooser.dart';
import 'package:hustle_stay/screens/requests/stats/request_stats.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';
import 'package:hustle_stay/widgets/requests/student_view.dart';

// ignore: must_be_immutable
class RequestsStatisticsPage extends ConsumerStatefulWidget {
  const RequestsStatisticsPage({super.key});

  @override
  ConsumerState<RequestsStatisticsPage> createState() =>
      _RequestsStatisticsPageState();
}

class _RequestsStatisticsPageState
    extends ConsumerState<RequestsStatisticsPage> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    filters = {
      "createdWithin": DateTimeRange(
        end: DateTime(now.year, now.month, now.day),
        start: DateTime(now.year, now.month, now.day - 30),
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                useSafeArea: true,
                builder: (ctx) => RequestsFilterChooserScreen(filters: filters),
              );
              setState(() {});
            },
            icon: const Icon(Icons.filter_alt_rounded),
          ),
          IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                useSafeArea: true,
                showDragHandle: true,
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      SelectOne(
                          title: 'Split Requests by',
                          subtitle: 'Compare the stats based on',
                          selectedOption: settings.requestsGroupBy,
                          allOptions: const {
                            'None',
                            'Hostel',
                            'Category',
                            'Status',
                            'Requesters',
                            'Approvers'
                          },
                          onChange: (value) {
                            setState(() {
                              settings.requestsGroupBy = value;
                            });
                            settingsClass.saveSettings();
                            return true;
                          }),
                      const Divider(),
                      SelectOne(
                          title: 'Graph Interval',
                          subtitle: 'Change x-axis interval by each',
                          selectedOption: settings.interval,
                          allOptions: const {
                            'Day',
                            'Month',
                            'Year',
                          },
                          onChange: (value) {
                            setState(() {
                              settings.interval = value;
                            });
                            settingsClass.saveSettings();
                            return true;
                          }),
                    ],
                  ),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: CacheBuilder(
        provider: _requestsProvider,
        src: Source.cache,
        loadingWidget: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circularProgressIndicator(),
            const Text('Fetching requests'),
          ],
        )),
        builder: (ctx, requests) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    try {
                      await _requestsProvider();
                      await fetchAllUserReadonlyProperties();
                      await fetchComplainees();
                      if (context.mounted) {
                        setState(() {});
                      }
                    } catch (e) {
                      showMsg(context, e.toString());
                    }
                    if (context.mounted) setState(() {});
                  },
                  child: UsersBuilder(
                    src: Source.cache,
                    builder: (ctx, users) => RequestsStats(
                      interval: settings.interval,
                      requests: requests,
                      groupBy: settings.requestsGroupBy,
                      users: users.fold({}, (previousValue, element) {
                        previousValue[element.email!] = element;
                        return previousValue;
                      }),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  navigatorPush(
                    context,
                    Scaffold(
                      appBar: AppBar(
                        // actions: [
                        //   IconButton(
                        //     onPressed: () => showSortDialog(context, ref),
                        //     icon: const Icon(Icons.compare_arrows_rounded),
                        //   ),
                        // ],
                        title: const Text('Matching Requests'),
                      ),
                      body: RequestsList(
                        requests: requests,
                        showPostRequestOptions: false,
                      ),
                    ),
                  );
                },
                child: Text(
                    "Total ${requests.length} requests match your criteria"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Request>> _requestsProvider({Source? src}) async {
    final docs = (await firestore
            .collection('requests')
            .get(src == null ? null : GetOptions(source: src)))
        .docs;
    for (var element in docs) {
      if (int.tryParse(element.id) == null) {
        Request.allApprovers[element.id] =
            (element.data()['approvers'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
      }
    }
    Iterable<Request> ans = docs
        .where((element) => int.tryParse(element.id) != null)
        .map((doc) => decodeToRequest(doc.data()));
    final DateTimeRange? createdWithin = filters['createdWithin'];
    final Set<RequestStatus>? status = filters['status'];
    final DateTimeRange? closedWithin = filters['closedWithin'];
    final Set<String> categories = filters['categories'] ?? {};
    final Set<String> approvers = filters['approvers'] ?? {};
    final Set<String> requesters = filters['requesters'] ?? {};

    if (createdWithin != null) {
      ans = ans.where((request) =>
          request.id >= createdWithin.start.millisecondsSinceEpoch &&
          request.id <= createdWithin.end.millisecondsSinceEpoch);
    }

    if (categories.isNotEmpty) {
      ans = ans.where((request) => categories.contains(request.type));
    }

    if (requesters.isNotEmpty) {
      ans = ans
          .where((request) => requesters.contains(request.requestingUserEmail));
    }

    if (status != null) {
      if (!status.contains(RequestStatus.pending) && closedWithin != null) {
        ans = ans.where((request) =>
            request.closedAt != 0 &&
            request.closedAt >= closedWithin.start.millisecondsSinceEpoch &&
            request.closedAt <= closedWithin.end.millisecondsSinceEpoch);
      } else {
        ans = ans.where((request) => status.contains(request.status));
      }
    }

    if (approvers.isNotEmpty) {
      ans = ans.where((request) {
        for (final element in request.approvers) {
          if (approvers.contains(element)) return true;
        }
        return false;
      });
    }
    return ans.toList();

    /// Use below code to fetch from server
    // Query<Map<String, dynamic>> collection = firestore.collection('requests');
    // final DateTimeRange? createdWithin = filters['createdWithin'];
    // final bool? resolved = filters['resolved'];
    // final DateTimeRange? resolvedWithin = filters['resolvedWithin'];
    // final Scope? scope = filters['scope'];
    // final List<String> categories = filters['categories'] ?? [];
    // final List<String> complainees = filters['complainees'] ?? [];
    // final List<String> complainants = filters['complainants'] ?? [];
    // if (createdWithin != null) {
    //   collection = collection
    //       .where('createdAt',
    //           isGreaterThanOrEqualTo:
    //               createdWithin.start.millisecondsSinceEpoch)
    //       .where('createdAt',
    //           isLessThanOrEqualTo: createdWithin.end.millisecondsSinceEpoch);
    // }
    // if (categories.isNotEmpty) {
    //   collection = collection.where('category', whereIn: categories);
    // }
    // if (complainants.isNotEmpty) {
    //   collection = collection.where('from', whereIn: complainants);
    // }
    // if (resolved != null) {
    //   collection = collection.where('resolved', isEqualTo: resolved);
    //   if (resolved && resolvedWithin != null) {
    //     collection = collection
    //         .where('resolvedAt',
    //             isGreaterThanOrEqualTo:
    //                 resolvedWithin.start.millisecondsSinceEpoch)
    //         .where('resolvedAt',
    //             isLessThanOrEqualTo: resolvedWithin.end.millisecondsSinceEpoch);
    //   }
    // }
    // if (scope != null) {
    //   collection = collection.where('scope', isEqualTo: scope.name);
    // }
    // if (complainees.isNotEmpty) {
    //   collection = collection.where('to', arrayContainsAny: complainees);
    // }
    // final docs =
    //     (await collection.get(src == null ? null : GetOptions(source: src)))
    //         .docs;
    // return [
    //   for (final doc in docs) requestData.load(int.parse(doc.id), doc.data())
    // ];
  }
}
