import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hustle_stay/tools.dart';

/// This is a widget which shows data from cache while data is being loaded from
/// the server. Rest of the time it shows [loadingWidget]
class CacheBuilder<content> extends StatelessWidget {
  final Widget Function(BuildContext ctx, content data) builder;
  final Future<content> Function({Source? src}) provider;
  final Source? src;
  final Widget? loadingWidget;
  const CacheBuilder({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.src,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: provider(src: src),
      builder: (ctx, snapshot) {
        if (snapshot.hasError && src == Source.cache) {
          return CacheBuilder(
            builder: builder,
            loadingWidget: loadingWidget,
            provider: provider,
          );
        }
        if (!snapshot.hasData) {
          if (src == Source.cache) {
            return loadingWidget ?? circularProgressIndicator();
          }
          return FutureBuilder(
            future: provider(src: Source.cache),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Returning this Widget when nothing has arrived
                return loadingWidget ?? circularProgressIndicator();
              }
              // Returning this widget from cache while data arrives from server
              return builder(ctx, snapshot.data as content);
            },
          );
        }
        // Returning this widget when data arrives from server
        return builder(ctx, snapshot.data as content);
      },
    );
  }
}
