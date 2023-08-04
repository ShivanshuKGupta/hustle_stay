import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class LoadingWidget extends StatelessWidget {
  final ValueNotifier<double> progress = ValueNotifier<double>(0);
  final Future<void> Function(
      BuildContext context, ValueNotifier<double> progress) builder;
  LoadingWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgressIndicator(),
          ValueListenableBuilder(
            valueListenable: progress,
            builder: (context, value, child) {
              return Text("${value.toString()}% done");
            },
          ),
        ],
      );
    });
  }
}
