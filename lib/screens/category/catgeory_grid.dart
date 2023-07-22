import 'package:flutter/material.dart';
import 'package:hustle_stay/models/category/category.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final String title;
  final Icon icon;
  final void Function(Category category) onTap;
  const CategoryList({
    super.key,
    required this.categories,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != 'Other')
                GridTileLogo(
                  onTap: () => Navigator.of(context).pop(),
                  title: title,
                  icon: icon,
                  color: Theme.of(context).colorScheme.background,
                ),
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
                    ...categories.map(
                      (entry) => GridTileLogo(
                        onTap: () => onTap(entry),
                        title: entry.id,
                        icon: const Icon(Icons.category_rounded, size: 50),
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
