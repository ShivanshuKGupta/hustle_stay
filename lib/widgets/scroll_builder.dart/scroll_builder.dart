import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/loading_elevated_button.dart';

class ScrollBuilder extends StatefulWidget {
  final Future<Iterable<Widget>> Function(
      BuildContext context, int start, int interval) loader;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final int interval;
  final Widget? loadingWidget;
  final bool automaticLoading;
  final ScrollController? scrollController;
  const ScrollBuilder({
    super.key,
    required this.loader,
    this.interval = 20,
    this.loadingWidget,
    this.automaticLoading = false,
    this.scrollController,
    this.separatorBuilder,
  });

  @override
  State<ScrollBuilder> createState() => _ScrollBuilderState();
}

class _ScrollBuilderState extends State<ScrollBuilder> {
  List<Widget> items = [];
  bool showLoadMore = true;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _loadMore(0).then((value) {
      if (context.mounted) {
        setState(() {
          initialized = true;
        });
      }
    }).onError((error, stackTrace) async {
      if (context.mounted) {
        showMsg(context, error.toString());
        setState(() {
          initialized = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !initialized
        ? Center(child: widget.loadingWidget ?? circularProgressIndicator())
        : ListView.separated(
            separatorBuilder:
                widget.separatorBuilder ?? (ctx, index) => Container(),
            // key: , add key here if the widgets rebuild on their own
            controller: widget.scrollController,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                if (widget.automaticLoading) {
                  _loadMore(index);
                  return widget.loadingWidget ?? circularProgressIndicator();
                }
                if (!showLoadMore) {
                  return Container();
                }
                return LoadingElevatedButton(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Load more'),
                  errorHandler: (err) {
                    // show retry button
                  },
                  onPressed: () async => await _loadMore(index),
                );
              }
              return items[index];
            },
          );
  }

  Future<void> _loadMore(int start) async {
    final newItems = await widget.loader(context, start, widget.interval);
    if (newItems.length < widget.interval) showLoadMore = false;
    if (context.mounted) {
      setState(() {
        items.addAll(newItems);
      });
    }
  }
}
