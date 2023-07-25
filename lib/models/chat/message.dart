import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/user/user.dart';

import 'chat.dart';

class MessageData {
  /// The datetime object representing the
  late String id;

  /// The markdown text
  late String txt;

  /// Sender of the message
  late String from;

  /// CreatedAt
  late DateTime createdAt;

  /// Modified At
  DateTime? modifiedAt;

  Set<String> readBy = {};

  /// These indicative messages are used to indicate
  /// that something has happened in the chat
  /// like the inclusion of someone in the chat
  /// can only be created but not deleted
  late bool indicative;

  MessageData({
    required this.id,
    required this.txt,
    required this.from,
    required this.createdAt,
    this.indicative = false,
    this.modifiedAt,
  });

  Map<String, dynamic> encode() {
    return {
      "txt": txt,
      "from": from,
      "indicative": indicative,
      "createdAt": createdAt.millisecondsSinceEpoch,
      if (modifiedAt != null) "modifiedAt": modifiedAt!.millisecondsSinceEpoch,
      "readBy": readBy.toList()
    };
  }

  MessageData.load(this.id, Map<String, dynamic> data) {
    txt = data["txt"];
    from = data["from"];
    createdAt = DateTime.fromMillisecondsSinceEpoch(data["createdAt"]);
    indicative = data["indicative"] ?? false;
    modifiedAt = data["modifiedAt"] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(data["modifiedAt"]);
    readBy = ((data['readBy'] ?? []) as List<dynamic>)
        .map((e) => e.toString())
        .toSet();
  }
}

Future<void> addMeInReadBy(ChatData chat, MessageData msg) async {
  final chatMessages = firestore.doc(chat.path).collection("chat");
  await chatMessages
      .doc(msg.id)
      .update({'readBy': msg.readBy..add(currentUser.email!)});
}

Future<void> addMessage(ChatData chat, MessageData msg) async {
  final chatMessages = firestore.doc(chat.path).collection("chat");
  await chatMessages
      .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(msg.encode());
}

Future<void> deleteMessage(ChatData chat, MessageData msg) async {
  final chatMessages = firestore.doc(chat.path).collection("chat");
  await chatMessages.doc(msg.id).delete();
}
