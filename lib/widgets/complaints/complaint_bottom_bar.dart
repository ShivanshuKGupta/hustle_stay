import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/chat/chat.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/complaint_list.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/choose_users.dart.dart';

// ignore: must_be_immutable
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
      ElevatedButton.icon(
        icon: const Icon(Icons.check_rounded),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => resolveComplaint(ref.read(complaintsList.notifier)),
        label: Text(
          (complaint.from != currentUser.email ? ' Request to ' : '') +
              (complaint.resolved ? 'Unresolve' : 'Resolve'),
        ),
      ),
      ElevatedButton.icon(
        icon: const Icon(Icons.person_add_rounded),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: showIncludeBox,
        label: Text(
            '${complaint.from != currentUser.email ? ' Request to ' : ''}Include'),
      ),
    ];
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.separated(
          separatorBuilder: (ctx, index) => const VerticalDivider(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) => Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: buttons[index],
          ),
          itemCount: buttons.length,
        ),
      ),
    );
  }

  Future<void> showIncludeBox() async {
    final allUsers = await fetchComplainees();
    List<String> chosenUsers = [];
    allUsers.removeWhere((element) => complaint.to.contains(element));
    if (context.mounted) {
      final response = await Navigator.of(context).push<bool?>(DialogRoute(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              scrollable: true,
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.only(top: 20),
              actionsAlignment: MainAxisAlignment.center,
              content: ChooseUsers(
                allUsers: allUsers,
                chosenUsers: chosenUsers,
                onUpdate: (newUsers) {
                  chosenUsers = newUsers;
                },
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Add'),
                )
              ],
            );
          }));
      if (response == true) {
        if (chosenUsers.isEmpty) {
          if (context.mounted) {
            showMsg(context, "Choose atleast one recepient.");
          }
          return;
        }
        if (complaint.from != currentUser.email) {
          await addMessage(
            ChatData(
              path: "complaints/${complaint.id}",
              owner: complaint.from,
              receivers: complaint.to,
              title: complaint.title,
              description: complaint.description,
            ),
            MessageData(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              txt:
                  "${currentUser.name ?? currentUser.email} requested to include $chosenUsers in the complaint.",
              from: currentUser.email!,
              createdAt: DateTime.now(),
              indicative: true,
            ),
          );
          return;
        }
        complaint.to.addAll(chosenUsers);
        await updateComplaint(complaint);
        await addMessage(
          ChatData(
            path: "complaints/${complaint.id}",
            owner: complaint.from,
            receivers: complaint.to,
            title: complaint.title,
            description: complaint.description,
          ),
          MessageData(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            txt:
                "${currentUser.name ?? currentUser.email} included $chosenUsers in the complaint",
            from: currentUser.email!,
            createdAt: DateTime.now(),
            indicative: true,
          ),
        );
      }
    }
  }

  void resolveComplaint(complaintListNotifier) async {
    if (complaint.from != currentUser.email) {
      await addMessage(
        ChatData(
          path: "complaints/${complaint.id}",
          owner: complaint.from,
          receivers: complaint.to,
          title: complaint.title,
          description: complaint.description,
        ),
        MessageData(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          txt:
              "${currentUser.name ?? currentUser.email} requested to ${complaint.resolved ? 'unresolve' : 'resolve'} the complaint at\n${ddmmyyyy(DateTime.now())} ${timeFrom(DateTime.now())}",
          from: currentUser.email!,
          createdAt: DateTime.now(),
          indicative: true,
        ),
      );
      return;
    }
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
      await addMessage(
        ChatData(
          path: "complaints/${complaint.id}",
          owner: complaint.from,
          receivers: complaint.to,
          title: complaint.title,
          description: complaint.description,
        ),
        MessageData(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          txt:
              "${currentUser.name ?? currentUser.email} ${complaint.resolved ? 'resolved' : 'unresolved'} the complaint at\n${ddmmyyyy(DateTime.now())} ${timeFrom(DateTime.now())}",
          from: currentUser.email!,
          createdAt: DateTime.now(),
          indicative: true,
        ),
      );
      if (complaint.resolved) {
        complaintListNotifier.removeComplaint(complaint);
      } else {
        complaintListNotifier.addComplaint(complaint);
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
