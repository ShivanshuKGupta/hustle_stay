import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/widgets/complaints/complaint_category_widget.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/settings/section.dart';

import '../../models/complaint/complaint.dart';
import '../../providers/settings.dart';

class ComplaintsListView extends ConsumerWidget {
  final List<ComplaintData> complaints;
  const ComplaintsListView({super.key, required this.complaints});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final mediaQuery = MediaQuery.of(context);
    List<Widget> children =
        calculateUI(settings.complaintsGrouping, complaints);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: complaints.isEmpty ? 0 : children.length + 1,
      itemBuilder: (ctx, index) {
        if (index == children.length) {
          return SizedBox(
            height: mediaQuery.padding.bottom,
          );
        }
        return children[index];
      },
    );
  }
}
