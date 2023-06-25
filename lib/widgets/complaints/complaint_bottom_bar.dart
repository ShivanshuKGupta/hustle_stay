import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/tools.dart';

class ComplaintBottomBar extends StatelessWidget {
  ComplaintData complaint;
  ComplaintBottomBar({
    super.key,
    required this.context,
    required this.complaint,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () async {
          String? response = await askUser(
            context,
            "Resolve the complaint?",
            description:
                "Do you confirm that the complaint has indeed been resolved from your perspective?",
            yes: true,
            no: true,
          );
          if (response == 'yes') {
            complaint.resolved = true;
            updateComplaint(complaint);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: const Text('Resolve'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {},
        child: const Text('Include'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {},
        child: const Text('Elevate'),
      ),
    ];
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: buttons,
      ),
    );
  }
}
