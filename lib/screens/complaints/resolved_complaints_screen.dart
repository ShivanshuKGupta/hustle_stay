import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/other/scroll_builder.dart';

class ResolvedComplaintsScreen extends StatelessWidget {
  final ScrollController? scrollController;
  ResolvedComplaintsScreen({super.key, this.scrollController});

  final Map<String, DocumentSnapshot> savePoint = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolved Complaints'),
      ),
      body: ScrollBuilder(
        scrollController: scrollController,
        loader: (context, start, interval) async {
          final complaints = await fetchComplaints(
            resolved: true,
            savePoint: savePoint,
            limit: interval,
          );
          return complaints.map(
            (complaint) => ComplaintListItem(
              complaint: complaint,
            ),
          );
        },
      ),
    );
  }
}

// Future<List<ComplaintData>> fetchResolvedComplaints({
//   required Map<String, DocumentSnapshot> savePoint,
//   required int limit,
//   Source? src,
// }) async {
//   // Fetching all public complaints
//   Query<Map<String, dynamic>> publicComplaints =
//       firestore.collection('complaints').where('scope', isEqualTo: 'public');

//   publicComplaints = publicComplaints
//       .where('resolvedAt', isNull: false)
//       .where('deletedAt', isNull: true)
//       .orderBy('resolvedAt');
//   if (savePoint['publicComplaints'] != null) {
//     publicComplaints =
//         publicComplaints.startAfterDocument(savePoint['publicComplaints']!);
//   }
//   QuerySnapshot<Map<String, dynamic>> response = await publicComplaints
//       .limit(limit)
//       .get(src == null ? null : GetOptions(source: src));
//   List<ComplaintData> ans = response.docs
//       .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
//       .toList();
//   if (response.docs.isNotEmpty) {
//     savePoint['publicComplaints'] = response.docs.last;
//   }

//   // Fetching Private Complaints made by the user itself
//   Query<Map<String, dynamic>> myComplaints = firestore
//       .collection('complaints')
//       .where('from', isEqualTo: currentUser.email)
//       .where('scope', isEqualTo: 'private');

//   myComplaints = myComplaints
//       .where('resolvedAt', isNull: false)
//       .where('deletedAt', isNull: true)
//       .orderBy('resolvedAt');

//   if (savePoint['myComplaints'] != null) {
//     myComplaints = myComplaints.startAfterDocument(savePoint['myComplaints']!);
//   }
//   response = await myComplaints
//       .limit(limit)
//       .get(src == null ? null : GetOptions(source: src));
//   ans += response.docs
//       .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
//       .toList();
//   if (response.docs.isNotEmpty) {
//     savePoint['myComplaints'] = response.docs.last;
//   }

//   // Fetching all complaints in which the user is included
//   Query<Map<String, dynamic>> includedComplaints = firestore
//       .collection('complaints')
//       .where('to', arrayContains: currentUser.email)
//       .where('scope', isEqualTo: 'private');

//   includedComplaints = includedComplaints
//       .where('resolvedAt', isNull: false)
//       .where('deletedAt', isNull: true)
//       .orderBy('resolvedAt');

//   if (savePoint['includedComplaints'] != null) {
//     includedComplaints =
//         includedComplaints.startAfterDocument(savePoint['includedComplaints']!);
//   }
//   response = await includedComplaints
//       .limit(limit)
//       .get(src == null ? null : GetOptions(source: src));
//   ans += response.docs
//       .map((e) => ComplaintData.load(int.parse(e.id), e.data()))
//       .toList();
//   if (response.docs.isNotEmpty) {
//     savePoint['includedComplaints'] = response.docs.last;
//   }

//   ans.sort((a, b) => (a.resolvedAt! < b.resolvedAt!) ? 1 : 0);
//   return ans;
// }
