import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/screens/category/category_grid.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class ComplaintCategoryView extends StatelessWidget {
  final String title;
  final void Function(Category category) onTap;
  const ComplaintCategoryView({
    super.key,
    this.title = 'Post a New Complaint',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: shaderText(
            context,
            title: title,
            style: theme.textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CategoriesBuilder(
            builder: (ctx, categories) {
              Map<String, List<Category>> groups = {};
              Map<String, Category> parents = {};
              for (var category in categories) {
                if (category.parent == null) {
                  allParents.add(category.id);
                  parents[category.id] = category;
                } else {
                  if (groups[category.parent!] == null) {
                    groups[category.parent!] = [];
                  }
                  groups[category.parent!]!.add(category);
                }
              }
              return GridView.extent(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                maxCrossAxisExtent: 320,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: [
                  ...parents.entries.map(
                    (entry) => GridTileLogo(
                      onTap: () {
                        if (groups[entry.key] == null ||
                            groups[entry.key]!.isEmpty) {
                          onTap(parents[entry.key]!);
                        } else {
                          navigatorPush(
                            context,
                            CategoryList(
                              onTap: onTap,
                              categories: groups[entry.key] ?? [],
                              category: parents[entry.key]!,
                            ),
                          );
                        }
                      },
                      title: entry.key,
                      icon: Icon(
                          parents[entry.key] != null
                              ? parents[entry.key]!.icon
                              : Icons.category_rounded,
                          size: 50),
                      color: parents[entry.key] != null
                          ? parents[entry.key]!.color
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
