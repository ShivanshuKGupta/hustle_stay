import 'package:riverpod/riverpod.dart';
import 'user.dart';
import "package:http/http.dart" as https;

enum ComplaintType {
  cleaning,
  electricity,
  emergency,
  maintenance,
  water,
  other,
}

class Complaint {
  String? id;
  ComplaintType cType;
  String heading;
  String body;
  String location;

  User poster;
  DateTime entryTime = DateTime.now();

  Complaint({
    required this.location,
    required this.cType,
    required this.heading,
    required this.poster,
    required this.body,
  });
}

class ComplaintNotifier extends StateNotifier<List<Complaint>> {
  ComplaintNotifier() : super([]);

  post(Complaint complaint) async {
    final url =
        Uri.https("hustlestay-default-rtdb.firebaseio.com", "complaints.json");
    final response = await https.post(url);
    print(response.body);
    state = [...state, complaint];
  }

  get() async {
    final url =
        Uri.https("hustlestay-default-rtdb.firebaseio.com", "complaints.json");
    final response = await https.get(url);
    print(response.body);
    // state = response.body;
  }
}

final complaintProvider =
    StateNotifierProvider<ComplaintNotifier, List<Complaint>>((ref) {
  return ComplaintNotifier();
});
