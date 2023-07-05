import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';

class _ComplaintListProvider extends StateNotifier<List<ComplaintData>> {
  _ComplaintListProvider() : super(const []);

  void addComplaint(ComplaintData complaint) {
    state.insert(0, complaint);
    notifyListeners();
  }

  void removeComplaint(ComplaintData complaint) {
    state.removeWhere((element) => element.id == complaint.id);
    notifyListeners();
  }

  void updateList(List<ComplaintData> newList) {
    state = newList;
    notifyListeners();
  }

  /// If watch listeners do not react to changes automatically,
  /// then use this function to notify all watch listeners
  void notifyListeners() {
    final List<ComplaintData> newList = state;
    state = [];
    state = newList;
  }
}

/// use notifier on this object to access the settings class
final complaintsList =
    StateNotifierProvider<_ComplaintListProvider, List<ComplaintData>>(
        (ref) => _ComplaintListProvider());
