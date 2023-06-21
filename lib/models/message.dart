import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hustle_stay/providers/image.dart';

import 'chat.dart';

class MessageData {
  late String id;

  /// The markdown text
  late String txt;

  /// Sender of the message
  late String from;

  /// CreatedAt
  late DateTime createdAt;

  /// Modified At
  DateTime? modifiedAt;

  MessageData({
    required this.id,
    required this.txt,
    required this.from,
    required this.createdAt,
    // TODO: add another field readBy
    this.modifiedAt,
  });

  Map<String, dynamic> encode() {
    return {
      "txt": txt,
      "from": from,
      "createdAt": createdAt.millisecondsSinceEpoch,
      if (modifiedAt != null) "modifiedAt": modifiedAt!.millisecondsSinceEpoch,
    };
  }

  MessageData.load(this.id, Map<String, dynamic> data) {
    txt = data["txt"];
    from = data["from"];
    createdAt = DateTime.fromMillisecondsSinceEpoch(data["createdAt"]);
    modifiedAt = data["modifiedAt"] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(data["modifiedAt"]);
  }
}

Future<void> addMessage(ChatData chat, MessageData msg) async {
  final store = FirebaseFirestore.instance;
  final chatMessages = store.doc(chat.path).collection("chat");
  await chatMessages
      .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(msg.encode());
}

Future<void> deleteMessage(ChatData chat, MessageData msg) async {
  final store = FirebaseFirestore.instance;
  final chatMessages = store.doc(chat.path).collection("chat");
  await chatMessages.doc(msg.id).delete();
}
