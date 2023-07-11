import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/filter_screen/filter_choser_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_category_widget.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/settings/section.dart';

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

  List<Widget> calculateUI(String groupBy, List<ComplaintData> complaints) {
    if (groupBy != 'none') {
      Map<String, List<ComplaintData>> categoriesMap = {};
      for (var element in complaints) {
        String category = "";
        if (groupBy == 'category') {
          category = element.category ?? "Other";
        } else if (groupBy == 'scope') {
          category = element.scope.name;
        } else if (groupBy == 'complainant') {
          category = element.from;
        } else {
          throw "No matching groupBy field found";
        }
        if (categoriesMap.containsKey(category)) {
          categoriesMap[category]!.add(element);
        } else {
          categoriesMap[category] = [element];
        }
      }
      return categoriesMap.entries.map(
        (entry) {
          if (groupBy == 'category') {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ComplaintCategory(
                id: entry.key,
                complaints: entry.value,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Section(
              title: entry.key,
              children: entry.value
                  .map(
                    (e) => ComplaintListItem(
                      complaint: e,
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ).toList();
    }
    return complaints
        .map(
          (e) => ComplaintListItem(
            complaint: e,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final mediaQuery = MediaQuery.of(context);
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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                enableDrag: true,
                builder: (ctx) => const Text('Select sorting criteria here'),
              );
            },
            icon: const Icon(Icons.swap_vert_rounded),
          ),
        ],
      ),
      body: ComplaintsBuilder(
        complaintsProvider: _complaintsProvider,
        src: Source.cache,
        loadingWidget: AnimateIcon(
          onTap: () {},
          iconType: IconType.continueAnimation,
          animateIcon: AnimateIcons.loading5,
        ),
        builder: (ctx, complaints) {
          List<Widget> children =
              calculateUI(settings.complaintsGrouping, complaints);
          return RefreshIndicator(
            onRefresh: () async {
              try {
                await _complaintsProvider();
              } catch (e) {
                showMsg(context, e.toString());
              }
              if (context.mounted) {
                setState(() {});
              }
            },
            child: ListView.builder(
              itemCount: complaints.isEmpty ? 1 : children.length + 2,
              itemBuilder: complaints.isEmpty
                  ? (ctx, index) {
                      return SizedBox(
                        height: mediaQuery.size.height -
                            mediaQuery.viewInsets.top -
                            mediaQuery.padding.top -
                            mediaQuery.padding.bottom -
                            mediaQuery.viewInsets.bottom -
                            150,
                        child: Center(
                          child: Text(
                            'No Complaints Match the filters',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  : (ctx, index) {
                      if (index == 0) {
                        return Center(
                            child: Text(
                                "${complaints.length} total matches found"));
                      } else if (index == children.length + 1) {
                        return SizedBox(
                          height: mediaQuery.padding.bottom,
                        );
                      } else {
                        index--;
                      }
                      return children[index];
                    },
            ),
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
    print(docs);
    return [
      for (final doc in docs) ComplaintData.load(int.parse(doc.id), doc.data())
    ];
  }
}
