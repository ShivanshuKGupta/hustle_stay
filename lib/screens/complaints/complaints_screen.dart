import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/drawers/main_drawer.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_category_view.dart';
import 'package:hustle_stay/widgets/complaints/complaint_category_widget.dart';
import 'package:hustle_stay/widgets/complaints/complaint_form.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/settings/section.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  static Source src = Source.serverAndCache;

  // SliverAppBar get sliverAppBar => SliverAppBar(
  //       elevation: 10,
  //       floating: true,
  //       pinned: true,
  //       expandedHeight: 150,
  //       stretch: true,
  //       flexibleSpace: FlexibleSpaceBar(
  //         title: shaderText(
  //           context,
  //           title: "Complaints",
  //           style: Theme.of(context)
  //               .textTheme
  //               .titleLarge!
  //               .copyWith(fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       actions: [
  //         if (currentUser.readonly.isAdmin)
  //           IconButton(
  //             onPressed: () => navigatorPush(context, const StatisticsPage()),
  //             icon: const Icon(Icons.insert_chart_outlined_sharp),
  //           ),
  //         IconButton(
  //           onPressed: () => showSortDialog(context, ref),
  //           icon: const Icon(Icons.compare_arrows_rounded),
  //         ),
  //         IconButton(
  //           onPressed: _addComplaint,
  //           icon: const Icon(Icons.add_rounded),
  //         ),
  //       ],
  //     );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSortDialog(context, ref),
        child: const Icon(Icons.compare_arrows_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
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
            onRefresh: () async {
              try {
                await fetchAllCategories();
                await fetchComplaints();
              } catch (e) {
                showMsg(context, e.toString());
              }
              src = Source.serverAndCache;
              if (context.mounted) {
                setState(() {});
              }
            },
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                if (index == 0) {
                  return currentUser.readonly.type == 'student' ||
                          currentUser.email == 'code_soc@students.iiitr.ac.in'
                      ? ComplaintCategoryView(
                          onTap: (category) {
                            navigatorPush(
                              context,
                              ComplaintForm(
                                  category: category,
                                  afterSubmit: _afterAddComplaint),
                            );
                            // _addComplaint(category);
                          },
                        )
                      : Container();
                } else if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: shaderText(
                      context,
                      title:
                          '${currentUser.readonly.type == 'student' ? 'Your' : 'Pending'} Complaints',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (index == children.length + 2) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children.isEmpty
                        ? [
                            AnimateIcon(
                              onTap: () {},
                              iconType: IconType.continueAnimation,
                              animateIcon: AnimateIcons.cool,
                            ),
                            Text(
                              currentUser.readonly.type == 'student'
                                  ? 'There aren\'t any Complaints Yet'
                                  : 'No Pending Complaints Yet',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ]
                        : [],
                  );
                } else {
                  index -= 2;
                }
                return children[index];
              },
              itemCount: children.length + 3,
            ),
          );
        },
      ),
    );
  }

  List<Widget> calculateUI(
    String groupBy,
    List<ComplaintData> complaints,
  ) {
    if (groupBy != 'none') {
      Map<String, List<ComplaintData>> categoriesMap = {};
      for (var element in complaints) {
        String key = "";
        if (groupBy == 'category') {
          key = element.category ?? "Other";
        } else if (groupBy == 'scope') {
          key = element.scope.name;
        } else if (groupBy == 'complainant') {
          key = element.from;
        } else {
          throw "No matching groupBy field found";
        }
        if (categoriesMap.containsKey(key)) {
          categoriesMap[key]!.add(element);
        } else {
          categoriesMap[key] = [element];
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

  Future<void> _afterAddComplaint(ComplaintData complaint) async {
    setState(() {});
  }
}

Future<void> showSortDialog(BuildContext context, WidgetRef ref) async {
  final settings = ref.watch(settingsProvider);
  final settingsClass = ref.read(settingsProvider.notifier);
  settings.complaintsGrouping = await showDialog<String?>(
        context: context,
        builder: (ctx) => SortDialogBox(groupBy: settings.complaintsGrouping),
      ) ??
      settings.complaintsGrouping;
  settingsClass.notifyListeners();
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
