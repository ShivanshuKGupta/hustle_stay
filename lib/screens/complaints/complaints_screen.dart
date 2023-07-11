import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/screens/complaints/resolved_complaints_screen.dart';
import 'package:hustle_stay/screens/drawers/main_drawer.dart';
import 'package:hustle_stay/screens/filter_screen/stats_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/complaint_template_message.dart';
import 'package:hustle_stay/widgets/complaints/complaint_category_widget.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/settings/section.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  static Source src = Source.serverAndCache;

  SliverAppBar get sliverAppBar => SliverAppBar(
        elevation: 10,
        floating: true,
        pinned: true,
        expandedHeight: 150,
        stretch: true,
        flexibleSpace: FlexibleSpaceBar(
          title: shaderText(
            context,
            title: "Complaints",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => navigatorPush(context, const StatisticsPage()),
            icon: const Icon(Icons.donut_large_rounded),
          ),
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.compare_arrows_rounded),
          ),
          IconButton(
            onPressed: _addComplaint,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final mediaQuery = MediaQuery.of(context);
    final appBar = sliverAppBar;
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const MainDrawer(),
      body: ComplaintsBuilder(
        src: src,
        loadingWidget: Center(child: circularProgressIndicator()),
        builder: (ctx, complaints) {
          src = Source.cache;
          List<Widget> children =
              calculateUI(settings.complaintsGrouping, complaints);
          return RefreshIndicator(
            edgeOffset: (appBar.expandedHeight ?? 0) + appBar.toolbarHeight,
            onRefresh: () async {
              try {
                await fetchComplaints();
              } catch (e) {
                showMsg(context, e.toString());
              }
              src = Source.serverAndCache;
              if (context.mounted) {
                setState(() {});
              }
            },
            child: CustomScrollView(
              slivers: [
                appBar,
                SliverList(
                  delegate: complaints.isEmpty
                      ? SliverChildListDelegate(
                          [
                            SizedBox(
                              height: mediaQuery.size.height -
                                  mediaQuery.viewInsets.top -
                                  mediaQuery.padding.top -
                                  mediaQuery.padding.bottom -
                                  mediaQuery.viewInsets.bottom -
                                  150,
                              child: Center(
                                child: Text(
                                  'All clear✨',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : SliverChildBuilderDelegate(
                          (ctx, index) {
                            if (index == 0) {
                              return Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text("${complaints.length} pending and"),
                                  InkWell(
                                    onTap: () {
                                      navigatorPush(context,
                                          const ResolvedComplaintsScreen());
                                    },
                                    child: FutureBuilder(
                                      future: getComplaintsCount(),
                                      builder: (ctx, snapshot) => Text(
                                        " ${snapshot.data ?? 0} resolved ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                    ),
                                  ),
                                  const Text("in the last 30 days"),
                                ],
                              );
                            } else if (index == children.length + 1) {
                              return SizedBox(
                                height: mediaQuery.padding.bottom,
                              );
                            } else {
                              index--;
                            }
                            return children[index];
                          },
                          childCount: children.length + 2,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

  Future<void> _addComplaint() async {
    ComplaintData? complaint = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const EditComplaintsPage(),
      ),
    );
    if (complaint != null) {
      setState(() {});
      if (context.mounted) {
        showComplaintChat(
          context,
          complaint,
          initialMsg: MessageData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            from: currentUser.email!,
            createdAt: DateTime.now(),
            txt: templateMessage(complaint),
          ),
        );
      }
    }
  }

  Future<void> _showSortDialog() async {
    final settings = ref.watch(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    settings.complaintsGrouping = await showDialog<String?>(
          context: context,
          builder: (ctx) => SortDialogBox(groupBy: settings.complaintsGrouping),
        ) ??
        settings.complaintsGrouping;
    settingsClass.notifyListeners();
  }
}

// ignore: must_be_immutable
class SortDialogBox extends StatefulWidget {
  String groupBy;
  SortDialogBox({
    super.key,
    required this.groupBy,
  });

  @override
  State<SortDialogBox> createState() => _SortDialogBoxState();
}

class _SortDialogBoxState extends State<SortDialogBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      alignment: Alignment.topRight,
      elevation: 0,
      title: const Text('Group by'),
      actions: [
        DropdownButton(
          hint: const Text('Group by'),
          borderRadius: BorderRadius.circular(20),
          icon: const Icon(Icons.sort_rounded),
          value: widget.groupBy,
          items: const [
            DropdownMenuItem(
              value: 'none',
              child: Text('No Grouping'),
            ),
            DropdownMenuItem(
              value: 'category',
              child: Text('Category'),
            ),
            DropdownMenuItem(
              value: 'scope',
              child: Text('Public/Private'),
            ),
            DropdownMenuItem(
              value: 'complainant',
              child: Text('Complainant'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              widget.groupBy = value ?? "none";
            });
          },
          // ),
          // DropdownButton(
          //   hint: const Text('Sort Groups by'),
          //   borderRadius: BorderRadius.circular(20),
          //   icon: const Icon(Icons.sort_rounded),
          //   value: parameters.sortGroupsBy,
          //   items: const [
          //     DropdownMenuItem(
          //       value: 'time',
          //       child: Text('Date Created'),
          //     ),
          //     DropdownMenuItem(
          //       value: 'priority',
          //       child: Text('Category'),
          //     ),
          //     DropdownMenuItem(
          //       value: 'alpha',
          //       child: Text('Alphabetical'),
          //     ),
          //   ],
          //   onChanged: (value) {
          //     parameters.sortEntriesBy = value ?? "time";
          //   },
          // ),
          // DropdownButton(
          //   hint: const Text('Order'),
          //   borderRadius: BorderRadius.circular(20),
          //   icon: const Icon(Icons.sort_rounded),
          //   value: parameters.groupOrdering.index,
          //   items: Order.values
          //       .map(
          //         (e) => DropdownMenuItem(
          //           value: e.index,
          //           child: Text(e.name),
          //         ),
          //       )
          //       .toList(),
          //   onChanged: (value) {
          //     parameters.groupOrdering = Order.values[value ?? 1];
          //   },
          // ),
          // DropdownButton(
          //   hint: const Text('Sort Entries by'),
          //   borderRadius: BorderRadius.circular(20),
          //   icon: const Icon(Icons.sort_rounded),
          //   value: parameters.sortEntriesBy,
          //   items: const [
          //     DropdownMenuItem(
          //       value: 'time',
          //       child: Text('Date Created'),
          //     ),
          //     DropdownMenuItem(
          //       value: 'priority',
          //       child: Text('Category'),
          //     ),
          //     DropdownMenuItem(
          //       value: 'alpha',
          //       child: Text('Alphabetical'),
          //     ),
          //   ],
          //   onChanged: (value) {
          //     parameters.sortEntriesBy = value ?? "time";
          //   },
          // ),
          // DropdownButton(
          //   hint: const Text('Order'),
          //   borderRadius: BorderRadius.circular(20),
          //   icon: const Icon(Icons.sort_rounded),
          //   value: parameters.entriesOrdering.index,
          //   items: Order.values
          //       .map(
          //         (e) => DropdownMenuItem(
          //           value: e.index,
          //           child: Text(e.name),
          //         ),
          //       )
          //       .toList(),
          //   onChanged: (value) {
          //     parameters.entriesOrdering = Order.values[value ?? 1];
          //   },
          // ),
          // ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(widget.groupBy);
          },
          icon: const Icon(Icons.done_rounded),
          label: const Text('Apply'),
        ),
      ],
    );
  }
}
