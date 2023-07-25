import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Category category;
  final void Function(Category category) onTap;
  const CategoryList({
    super.key,
    required this.categories,
    required this.onTap,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: category.id.replaceAll('_', ' ')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (category.id != 'Other')
              //   GridTileLogo(
              //     onTap: () => Navigator.of(context).pop(),
              //     title: category.id,
              //     icon: Icon(category.icon, size: 50),
              //     color: Theme.of(context).colorScheme.background,
              //   ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.extent(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  maxCrossAxisExtent: 320,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  children: [
                    ...(categories.map((e) => e).toList()..add(category)).map(
                      (entry) => GridTileLogo(
                        onTap: () => onTap(entry),
                        title: entry.id == category.id ? 'Other' : entry.id,
                        icon: Icon(
                          entry.id == category.id
                              ? Icons.more_horiz_rounded
                              : entry.icon,
                          size: 50,
                        ),
                        color: entry.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
