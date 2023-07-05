import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/screens/complaints/resolved_complaints_screen.dart';
import 'package:hustle_stay/screens/drawers/main_drawer.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/complaint_template_message.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 1000);
    final mediaQuery = MediaQuery.of(context);
    final appBar = SliverAppBar(
      elevation: 10,
      floating: true,
      pinned: true,
      expandedHeight: 150,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: shaderText(
          context,
          title: "Complaints",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _addComplaint,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
    return Scaffold(
      drawer: const MainDrawer(),
      body: ComplaintsBuilder(
        loadingWidget: Center(child: circularProgressIndicator()),
        builder: (ctx, complaints) => RefreshIndicator(
          edgeOffset: appBar.collapsedHeight ?? 0,
          onRefresh: () async {
            await fetchComplaints();
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              appBar,
              SliverList(
                delegate: complaints.isEmpty
                    ? SliverChildListDelegate(
                        [
                          SizedBox(
                            height: mediaQuery.size.height -
                                mediaQuery.viewInsets.top -
                                mediaQuery.padding.top -
                                mediaQuery.padding.bottom -
                                mediaQuery.viewInsets.bottom -
                                150,
                            child: Center(
                              child: Text(
                                'All clear✨',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SliverChildBuilderDelegate(
                        (ctx, index) {
                          if (index == 0) {
                            return Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text("${complaints.length} pending and"),
                                InkWell(
                                  onTap: () {
                                    navigatorPush(context,
                                        const ResolvedComplaintsScreen());
                                  },
                                  child: Text(
                                    " 23 resolved ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ),
                                const Text("in the last 30 days"),
                              ],
                            );
                          } else if (index == complaints.length + 1) {
                            return SizedBox(
                              height: mediaQuery.padding.bottom,
                            );
                          } else {
                            index--;
                          }
                          final complaint = complaints[index];
                          return ComplaintListItem(
                            complaint: complaint,
                          );
                        },
                        childCount: complaints.length + 2,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addComplaint() async {
    ComplaintData? complaint = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const EditComplaintsPage(),
      ),
    );
    if (complaint != null) {
      setState(() {});
      if (context.mounted) {
        showComplaintChat(
          context,
          complaint,
          initialMsg: MessageData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            from: currentUser.email!,
            createdAt: DateTime.now(),
            txt: templateMessage(complaint),
          ),
        );
      }
    }
  }
}
