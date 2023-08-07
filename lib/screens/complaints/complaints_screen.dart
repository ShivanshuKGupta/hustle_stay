import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/screens/complaints/resolved_complaints_screen.dart';
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
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ComplaintsBuilder(
            loadingWidget: Center(child: circularProgressIndicator()),
            builder: (ctx, complaints) {
              List<Widget> children =
                  calculateUI(settings.complaintsGrouping, complaints);
              return RefreshIndicator(
                onRefresh: () async {
                  try {
                    await fetchAllCategories();
                    await initializeComplaints();
                  } catch (e) {
                    showMsg(context, e.toString());
                  }
                  if (context.mounted) {
                    setState(() {});
                  }
                },
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    if (index == 0) {
                      return currentUser.permissions.complaints.create == true
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
                          title: 'Pending Complaints',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
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
                                  currentUser.type == 'student'
                                      ? 'There aren\'t any Complaints Yet'
                                      : 'No Pending Complaints Yet',
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ]
                            : [
                                const SizedBox(height: 40),
                              ],
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
          SafeArea(
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  builder: (context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      builder: (context, scrollController) {
                        return ResolvedComplaintsScreen(
                          scrollController: scrollController,
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('Resolved Complaints'),
            ),
          ),
        ],
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
