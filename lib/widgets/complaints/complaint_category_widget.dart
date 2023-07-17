import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

// ignore: must_be_immutable
class ComplaintCategory extends StatefulWidget {
  final String id;
  final List<ComplaintData> complaints;
  const ComplaintCategory({
    super.key,
    required this.id,
    required this.complaints,
  });

  @override
  State<ComplaintCategory> createState() => _ComplaintCategoryState();
}

class _ComplaintCategoryState extends State<ComplaintCategory> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return CategoryBuilder(
      // src: Source.cache,
      id: widget.id,
      builder: (ctx, category) => GlassWidget(
        radius: 27,
        child: Container(
          color: category.color.withOpacity(0.2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: InkWell(
                  onTap: () => setState(() {
                    expanded = !expanded;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${widget.id} Complaints"),
                        Icon(expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              if (expanded)
                ...widget.complaints.map(
                  (e) => ComplaintListItem(complaint: e),
                ),
            ],
          ),
        ),
      ),
    ).animate().fade();
  }
}
