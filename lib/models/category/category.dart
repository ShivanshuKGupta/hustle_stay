import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/tools.dart';

class Category {
  final String id;
  String? defaultReceipient;
  List<String> allReceipients;
  // Higher the number higer is the priority
  int defaultPriority;
  // cooldown time after which we can add another receipient
  Duration cooldown;
  // just for UI purposes
  Color color;
  // logo url
  String? logoUrl;

  Category(
    this.id, {
    this.defaultReceipient,
    this.allReceipients = const [],
    this.cooldown = const Duration(seconds: 0),
    this.color = Colors.blue,
    this.logoUrl,
    this.defaultPriority = 0,
  });

  Map<String, dynamic> encode() {
    return {
      "defaultReceipient": defaultReceipient,
      "allReceipients": allReceipients,
      "defaultPriority": defaultPriority,
      "cooldown": cooldown.inSeconds,
      "color": color.value,
      "logoUrl": logoUrl,
    };
  }

  void load(Map<String, dynamic> data) {
    defaultReceipient = data['defaultReceipient'];
    allReceipients = data['allReceipients'];
    defaultPriority = data['defaultPriority'];
    cooldown = Duration(seconds: data['cooldown']);
    color = Color(data['color']);
    logoUrl = data['logoUrl'];
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
  category.load(response?.data() ?? {});
  return category;
}

Future<List<Category>> fetchCategories(List<String> ids, {Source? src}) async {
  return [for (final id in ids) await fetchCategory(id, src: src)];
}

Future<void> updateCategory(Category category) async {
  await firestore
      .collection('categories')
      .doc(category.id)
      .set(category.encode());
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
