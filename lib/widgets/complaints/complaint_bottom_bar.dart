import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/providers/complaint_list.dart';
import 'package:hustle_stay/tools.dart';

class ComplaintBottomBar extends ConsumerWidget {
  ComplaintData complaint;
  ComplaintBottomBar({
    super.key,
    required this.context,
    required this.complaint,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            "${complaint.resolved ? 'Unresolve' : 'Resolve'} the complaint?",
            description: complaint.resolved
                ? "Unresolving the complaint will activate this complaint again."
                : "Do you confirm that the complaint has indeed been resolved from your perspective?",
            yes: true,
            no: true,
          );
          if (response == 'yes') {
            complaint.resolved = !complaint.resolved;
            updateComplaint(complaint);
            if (complaint.resolved) {
              ref.read(complaintsList.notifier).removeComplaint(complaint);
            } else {
              ref.read(complaintsList.notifier).addComplaint(complaint);
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Text(complaint.resolved ? 'Unresolve' : 'Resolve'),
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
