import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/tools.dart';

Set<String> allParents = {};

enum Priority { low, medium, high }

class Category {
  String id;
  List<String> defaultReceipient;
  List<String> allrecipients;
  int modifiedAt = 0;

  /// Higher the number higer is the priority
  Priority defaultPriority;

  /// cooldown time after which we can add another receipient
  // Duration cooldown;

  /// just for UI purposes
  Color color;

  /// logo url
  IconData icon;

  /// The parent of this category
  /// This parent will be used to make this as a sub-category in parent category
  String? parent;

  Category(
    this.id, {
    this.defaultReceipient = const [],
    this.allrecipients = const [],
    // this.cooldown = const Duration(seconds: 0),
    this.color = Colors.blue,
    this.icon = Icons.category_rounded,
    this.defaultPriority = Priority.low,
    this.parent = 'Other',
  });

  Map<String, dynamic> encode() {
    return {
      if (defaultReceipient.isNotEmpty) "defaultReceipient": defaultReceipient,
      if (allrecipients.isNotEmpty) "allrecipients": allrecipients,
      "defaultPriority": defaultPriority.index,
      // "cooldown": cooldown.inSeconds,
      "color": color.value,
      "modifiedAt": modifiedAt,
      "icon": {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
      },
      "parent": parent == null ? null : parent!.trim(),
    };
  }

  void load(Map<String, dynamic> data) {
    defaultReceipient = ((data["defaultReceipient"] ?? []) as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    allrecipients = ((data["allrecipients"] ?? []) as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    defaultPriority = Priority.values[data['defaultPriority'] ?? 0];
    modifiedAt = data['modifiedAt'] ?? modifiedAt;
    // cooldown = Duration(seconds: data['cooldown'] ?? 0);
    color = Color(data['color'] ?? 0);
    if (data['icon'] != null) {
      icon = IconData(
        data['icon']!['codePoint'],
        fontFamily: data['icon']!['fontFamily'],
      );
    }
    parent = data['parent'];
    if (parent != null) {
      allParents.add(parent!);
    }
    // updateCategory(this);
  }
}

ValueNotifier<String?> categoriesInitialized = ValueNotifier(null);

Future<void> initializeCategories() async {
  categoriesInitialized.value = "Fetching Categories";
  const String key = 'categoriesLastModifiedAt';
  int catgeoriesLastModifiedAt = prefs!.getInt(key) ?? -1;
  final catgeories = await fetchAllCategories(
    lastModifiedAt: catgeoriesLastModifiedAt,
    src: Source.serverAndCache,
  );
  int maxModifiedAt = catgeoriesLastModifiedAt;
  for (var category in catgeories) {
    maxModifiedAt = max(maxModifiedAt, category.modifiedAt);
  }
  prefs!.setInt(key, maxModifiedAt);
  categoriesInitialized.value = null;
}

Future<Category> fetchCategory(String id) async {
  Category category = Category(id);
  DocumentSnapshot<Map<String, dynamic>>? response;
  response = await firestore.collection('categories').doc(id).get(
        const GetOptions(source: Source.cache),
      );
  category.load(response.data() ?? {});
  return category;
}

Future<List<Category>> fetchCategories(List<String> ids) async {
  return [for (final id in ids) await fetchCategory(id)];
}

Future<List<Category>> fetchAllCategories({
  int? lastModifiedAt,
  Source? src = Source.cache,
}) async {
  Query<Map<String, dynamic>> query = firestore.collection('categories');
  if (lastModifiedAt != null) {
    query = query.where('modifiedAt', isGreaterThan: lastModifiedAt);
  }
  final response =
      await query.get(src == null ? null : GetOptions(source: src));
  return response.docs
      .map((doc) => Category(doc.id)..load(doc.data()))
      .toList();
}

Future<void> updateCategory(Category category) async {
  if (category.parent != null) {
    category.allrecipients = [];
    category.defaultReceipient = [];
  }
  category.modifiedAt = DateTime.now().millisecondsSinceEpoch;
  await firestore
      .collection('categories')
      .doc(category.id)
      .set(category.encode());
}

// /// A widget used to display widget using category data
class CategoriesBuilder extends StatelessWidget {
  final Widget Function(BuildContext ctx, List<Category> categories) builder;
  final Widget? loadingWidget;
  final Source? src;
  const CategoriesBuilder({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.src,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchAllCategories(src: src),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          if (src == Source.cache) {
            return loadingWidget ?? circularProgressIndicator();
          }
          return FutureBuilder(
            future: fetchAllCategories(src: Source.cache),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                // Returning this Widget when nothing has arrived
                return loadingWidget ?? circularProgressIndicator();
              }
              // Returning this widget from cache while data arrives from server
              return builder(ctx, snapshot.data!);
            },
          );
        }
        // Returning this widget when data arrives from server
        return builder(ctx, snapshot.data!);
      },
    );
  }
}

/// A widget used to display widget using category data
class CategoryBuilder extends StatelessWidget {
  final String id;
  final Widget Function(BuildContext ctx, Category category) builder;
  final Widget? loadingWidget;
  const CategoryBuilder({
    super.key,
    required this.id,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchCategory(id),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return loadingWidget ?? circularProgressIndicator();
        }
        return builder(ctx, snapshot.data!);
      },
    );
  }
}
