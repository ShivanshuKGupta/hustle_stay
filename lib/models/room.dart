import 'package:hustle_stay/dummy_data.dart';
import 'package:hustle_stay/models/user.dart';

class Room {
  String id;
  List<String> students;
  Room({required this.id, required this.students});
  List<User> get getRoomates {
    return dummy_users
        .where((element) => students.contains(element.id))
        .toList();
  }
}
