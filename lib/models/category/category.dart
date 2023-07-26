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
    // defaultReceipient = defaultReceipient.map((e) {
    //   if (e == 'Attender') {
    //     return 'attender@iiitr.ac.in';
    //   } else if (e == 'Alka Chaddha') {
    //     return 'chiefwarden@iiitr.ac.in';
    //   }
    //   return e;
    // }).toList();
    allrecipients = ((data["allrecipients"] ?? []) as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    // allrecipients = allrecipients.map((e) {
    //   if (e == 'Attender') {
    //     return 'attender@iiitr.ac.in';
    //   } else if (e == 'Alka Chaddha') {
    //     return 'chiefwarden@iiitr.ac.in';
    //   }
    //   return e;
    // }).toList();
    defaultPriority = Priority.values[data['defaultPriority'] ?? 0];
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

Future<Category> fetchCategory(
  String id, {
  Source? src,
}) async {
  Category category = Category(id);
  DocumentSnapshot<Map<String, dynamic>>? response;
  try {
    /// Trying with given config
    response = await firestore.collection('categories').doc(id).get(
          src == null ? null : GetOptions(source: src),
        );
  } catch (e) {
    /// If failed then use default configuration
    if (src == Source.cache) {
      response = await firestore.collection('categories').doc(id).get();
    }
  }
  category.load(response!.data() ?? {});
  return category;
}

Future<List<Category>> fetchCategories(List<String> ids, {Source? src}) async {
  return [for (final id in ids) await fetchCategory(id, src: src)];
}

Future<List<Category>> fetchAllCategories({Source? src}) async {
  final response = await firestore
      .collection('categories')
      .get(src == null ? null : GetOptions(source: src));
  return response.docs
      .map((doc) => Category(doc.id)..load(doc.data()))
      .toList();
}

Future<void> updateCategory(Category category) async {
  if (category.parent != null) {
    category.allrecipients = [];
    category.defaultReceipient = [];
  }
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
  final Source? src;
  const CategoryBuilder({
    super.key,
    required this.id,
    required this.builder,
    this.loadingWidget,
    this.src,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchCategory(id),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          if (src == Source.cache) {
            return loadingWidget ?? circularProgressIndicator();
          }
          return FutureBuilder(
            future: fetchCategory(id, src: Source.cache),
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
