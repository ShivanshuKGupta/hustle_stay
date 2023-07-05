import 'package:flutter/material.dart';
import 'package:hustle_stay/models/chat/message.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/screens/drawers/main_drawer.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/complaint_template_message.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/complaints/complaints_list_widget.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 1000);
    return Scaffold(
        appBar: AppBar(
          title: shaderText(
            context,
            title: "Complaints",
          ),
          actions: [
            IconButton(
              onPressed: _addComplaint,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        drawer: const MainDrawer(),
        body: ComplaintsBuilder(
          loadingWidget: Center(child: circularProgressIndicator()),
          builder: (ctx, complaints) => RefreshIndicator(
            onRefresh: () async {
              await fetchComplaints();
              setState(() {});
            },
            child: ComplaintsListWidget(complaints: complaints),
          ),
        )
        // .animate().fade(begin: 0, end: 1, duration: duration).slideY(
        //       begin: -1,
        //       end: 0,
        //       curve: Curves.decelerate,
        //       duration: duration,
        //     ),
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
