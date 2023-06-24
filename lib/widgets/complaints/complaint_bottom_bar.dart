import 'package:flutter/material.dart';

class ComplaintBottomBar extends StatelessWidget {
  const ComplaintBottomBar({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 5),
        scrollDirection: Axis.horizontal,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  // fontWeight: FontWeight.bold,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Resolve'),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  // fontWeight: FontWeight.bold,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Include'),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  // fontWeight: FontWeight.bold,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Elevate'),
          ),
        ],
      ),
    );
  }
}
