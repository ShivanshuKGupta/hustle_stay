import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/complaints/complaints_screen.dart';
import 'package:hustle_stay/screens/filter_screen/filter_choser_screen.dart';
import 'package:hustle_stay/screens/filter_screen/stats.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaints_list_view.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';

// ignore: must_be_immutable
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
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
                builder: (ctx) => FilterChooserScreen(filters: filters),
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
                          title: 'Split Complaints by',
                          subtitle: 'Compare the stats based on',
                          selectedOption: settings.groupBy,
                          allOptions: const {
                            'None',
                            'Hostel',
                            'Category',
                            'Scope',
                            'Complainant',
                            'Complainee'
                          },
                          onChange: (value) {
                            setState(() {
                              settings.groupBy = value;
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
      body: ComplaintsBuilder(
        complaintsProvider: _complaintsProvider,
        src: Source.cache,
        loadingWidget: Center(child: circularProgressIndicator()),
        builder: (ctx, complaints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    try {
                      await _complaintsProvider();
                      await fetchAllUserReadonlyProperties();
                      await fetchComplainees();
                      await fetchAllCategories();
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
                    builder: (ctx, users) => Stats(
                      interval: settings.interval,
                      complaints: complaints,
                      groupBy: settings.groupBy,
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
                        actions: [
                          IconButton(
                            onPressed: () => showSortDialog(context, ref),
                            icon: const Icon(Icons.compare_arrows_rounded),
                          ),
                        ],
                        title: const Text('Matching Complaints'),
                      ),
                      body: ComplaintsListView(complaints: complaints),
                    ),
                  );
                },
                child: Text(
                    "Total ${complaints.length} complaints match your criteria"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<ComplaintData>> _complaintsProvider({Source? src}) async {
    final docs = (await firestore
            .collection('complaints')
            .get(src == null ? null : GetOptions(source: src)))
        .docs;
    Iterable<ComplaintData> ans =
        docs.map((doc) => ComplaintData.load(int.parse(doc.id), doc.data()));
    final DateTimeRange? createdWithin = filters['createdWithin'];
    final bool? resolved = filters['resolved'];
    final DateTimeRange? resolvedWithin = filters['resolvedWithin'];
    final Scope? scope = filters['scope'];
    final Set<String> categories = filters['categories'] ?? {};
    final Set<String> complainees = filters['complainees'] ?? {};
    final Set<String> complainants = filters['complainants'] ?? {};
    if (createdWithin != null) {
      ans = ans.where((complaint) =>
          complaint.id >= createdWithin.start.millisecondsSinceEpoch &&
          complaint.id <= createdWithin.end.millisecondsSinceEpoch);
    }
    if (categories.isNotEmpty) {
      ans = ans.where((complaint) => categories.contains(complaint.category));
    }
    if (complainants.isNotEmpty) {
      ans = ans.where((complaint) => complainants.contains(complaint.from));
    }
    if (resolved != null) {
      if (resolved == true && resolvedWithin != null) {
        ans = ans.where((complaint) =>
            complaint.resolvedAt != null &&
            complaint.resolvedAt! >=
                resolvedWithin.start.millisecondsSinceEpoch &&
            complaint.resolvedAt! <= resolvedWithin.end.millisecondsSinceEpoch);
      } else {
        ans =
            ans.where((complaint) => resolved ^ (complaint.resolvedAt == null));
      }
    }
    if (scope != null) {
      ans = ans.where((complaint) => complaint.scope == scope);
    }
    if (complainees.isNotEmpty) {
      ans = ans.where((complaint) {
        for (final element in complaint.to) {
          if (complainees.contains(element)) return true;
        }
        return false;
      });
    }
    return ans.toList();

    /// Use below code to fetch from server
    // Query<Map<String, dynamic>> collection = firestore.collection('complaints');
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
    //   for (final doc in docs) ComplaintData.load(int.parse(doc.id), doc.data())
    // ];
  }
}
