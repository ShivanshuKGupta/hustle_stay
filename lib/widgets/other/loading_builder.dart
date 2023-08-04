import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class LoadingBuilder extends StatefulWidget {
  final Future<Widget> Function(
      BuildContext context, ValueNotifier<double> progress) builder;
  final Widget Function(BuildContext context, double value, Widget? child)?
      loadingWidgetBuilder;
  const LoadingBuilder({
    super.key,
    required this.builder,
    this.loadingWidgetBuilder,
  });

  @override
  State<LoadingBuilder> createState() => _LoadingBuilderState();
}

class _LoadingBuilderState extends State<LoadingBuilder> {
  final ValueNotifier<double> progress = ValueNotifier<double>(0);

  int retryTimes = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: ValueKey("Loading_Builder_$retryTimes"),
      future: widget.builder(context, progress),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  setState(() {
                    retryTimes++;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                label: const Text('Retry'),
              ),
              Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.red),
              ),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ValueListenableBuilder(
              valueListenable: progress,
              builder: widget.loadingWidgetBuilder ??
                  (context, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        circularProgressIndicator(),
                        Text("${value.toString()}% done"),
                      ],
                    );
                  },
            ),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
