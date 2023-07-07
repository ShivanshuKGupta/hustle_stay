import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

class ComplaintCategory extends StatelessWidget {
  final String id;
  final List<ComplaintData> complaints;
  const ComplaintCategory({
    super.key,
    required this.id,
    required this.complaints,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryBuilder(
      id: id,
      builder: (ctx, category) => GlassWidget(
        radius: 20,
        child: Container(
          color: category.color.withOpacity(0.2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$id Complaints"),
                  const Icon(Icons.pie_chart_rounded),
                ],
              ),
            ),
            ...complaints.map(
              (e) => ComplaintListItem(complaint: e),
            ),
          ]),
        ),
      ),
    ).animate().fade();
  }
}
