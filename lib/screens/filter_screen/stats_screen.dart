import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/screens/filter_screen/filter_choser_screen.dart';
import 'package:hustle_stay/screens/filter_screen/stats.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaints_list_view.dart';

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
    // TODO: read any saved filter and assign it to filters
    filters = {};
  }

  @override
  Widget build(BuildContext context) {
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
              TextButton(
                onPressed: () {
                  navigatorPush(
                    context,
                    Scaffold(
                      appBar: AppBar(
                        actions: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                enableDrag: true,
                                builder: (ctx) =>
                                    const Text('Select sorting criteria here'),
                              );
                            },
                            icon: const Icon(Icons.swap_vert_rounded),
                          )
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    try {
                      await _complaintsProvider();
                    } catch (e) {
                      showMsg(context, e.toString());
                    }
                    if (context.mounted) setState(() {});
                  },
                  child: Stats(complaints: complaints),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<ComplaintData>> _complaintsProvider({Source? src}) async {
    Query<Map<String, dynamic>> collection = firestore.collection('complaints');
    final DateTimeRange? createdWithin = filters['createdWithin'];
    final bool? resolved = filters['resolved'];
    final DateTimeRange? resolvedWithin = filters['resolvedWithin'];
    final Scope? scope = filters['scope'];
    final List<String> categories = filters['categories'] ?? [];
    final List<String> complainees = filters['complainees'] ?? [];
    final List<String> complainants = filters['complainants'] ?? [];
    if (createdWithin != null) {
      collection = collection
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  createdWithin.start.millisecondsSinceEpoch)
          .where('createdAt',
              isLessThanOrEqualTo: createdWithin.end.millisecondsSinceEpoch);
    }
    if (categories.isNotEmpty) {
      collection = collection.where('category', whereIn: categories);
    }
    if (complainants.isNotEmpty) {
      collection = collection.where('from', whereIn: complainants);
    }
    if (resolved != null) {
      collection = collection.where('resolved', isEqualTo: resolved);
      if (resolved && resolvedWithin != null) {
        collection = collection
            .where('resolvedAt',
                isGreaterThanOrEqualTo:
                    resolvedWithin.start.millisecondsSinceEpoch)
            .where('resolvedAt',
                isLessThanOrEqualTo: resolvedWithin.end.millisecondsSinceEpoch);
      }
    }
    if (scope != null) {
      collection = collection.where('scope', isEqualTo: scope.name);
    }
    if (complainees.isNotEmpty) {
      collection = collection.where('to', arrayContainsAny: complainees);
    }
    final docs =
        (await collection.get(src == null ? null : GetOptions(source: src)))
            .docs;
    return [
      for (final doc in docs) ComplaintData.load(int.parse(doc.id), doc.data())
    ];
  }
}
