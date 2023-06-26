import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/providers/complaint_list.dart';
import 'package:hustle_stay/screens/complaints/edit_complaints_page.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/chat/complaint_template_message.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  bool _isLoading = false;

  bool _disposeWasCalled = false;

  Future<void> _updateComplaintsList() async {
    final complaints = ref.read(complaintsList);
    final complaintsNotifier = ref.read(complaintsList.notifier);
    List<ComplaintData> newComplaints = complaints;
    try {
      newComplaints = await fetchComplaints(src: Source.cache);
      if (!areComplaintsEqual(complaints, newComplaints)) {
        complaintsNotifier.updateList(newComplaints);
        if (!_disposeWasCalled) {
          setState(() {});
        }
      }
    } catch (e) {
      if (!_disposeWasCalled) {
        setState(() {
          _isLoading = true;
        });
      }
    }
    newComplaints = await fetchComplaints();
    if (!areComplaintsEqual(complaints, newComplaints)) {
      complaintsNotifier.updateList(newComplaints);
      if (!_disposeWasCalled) {
        setState(() {});
      }
    }
    _isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    _updateComplaintsList();
    _disposeWasCalled = false;
  }

  @override
  void dispose() {
    super.dispose();
    _disposeWasCalled = true;
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(complaintsList);
    return Scaffold(
      body: _isLoading && complaints.isEmpty
          ? Center(child: circularProgressIndicator())
          : _complaintsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addComplaint(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  /// Just a list view with a placeholder when there is no item in the list
  Widget _complaintsList() {
    final complaints = ref.watch(complaintsList);
    const duration = Duration(milliseconds: 400);
    final mediaQuery = MediaQuery.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        await _updateComplaintsList();
      },
      child: complaintsListWidget(
        context,
        complaints,
        mediaQuery,
        duration,
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
      _updateComplaintsList();
      if (context.mounted) {
        showComplaintChat(
          context,
          complaint,
          initialMsg: MessageData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            from: currentUser.email!,
            createdAt: DateTime.now(),
            txt: complaintTemplateMessage(complaint),
          ),
        );
      }
    }
  }
}

Widget complaintsListWidget(context, complaints, mediaQuery, duration) {
  int i = 0;
  return complaints.isEmpty
      ? ListView(
          children: [
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
      : ListView.builder(
          itemBuilder: (ctx, index) {
            final complaint = complaints[index];
            return ComplaintListItem(
              complaint: complaint,
            ).animate().then(delay: duration * i++).slideX(
                  begin: -1,
                  end: 0,
                  curve: Curves.decelerate,
                  duration: duration,
                );
          },
          itemCount: complaints.length,
        );
}

bool areComplaintsEqual(List<ComplaintData> A, List<ComplaintData> B) {
  if (A.length != B.length) return false;
  for (int i = A.length; i-- > 0;) {
    if (!isComplaintEqual(A[i], B[i])) return false;
  }
  return true;
}

bool isComplaintEqual(ComplaintData A, ComplaintData B) {
  return (A.encode().toString() == B.encode().toString());
}
