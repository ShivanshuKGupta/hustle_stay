import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/screens/category/catgeory_grid.dart';
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
              for (var category in categories) {
                if (groups[category.parent] == null) {
                  groups[category.parent] = [];
                }
                groups[category.parent]!.add(category);
              }
              return GridView.extent(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                maxCrossAxisExtent: 320,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: [
                  ...groups.entries.map(
                    (entry) => GridTileLogo(
                      onTap: () {
                        navigatorPush(
                          context,
                          CategoryList(
                            onTap: onTap,
                            categories: groups[entry.key]!,
                            title: entry.key,
                            icon: const Icon(Icons.category_rounded, size: 50),
                          ),
                        );
                      },
                      title: entry.key,
                      icon: const Icon(Icons.category_rounded, size: 50),
                      color: Colors.blue,
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
