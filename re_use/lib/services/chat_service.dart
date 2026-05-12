import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_use/types/chat.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ChatConversation>> watchConversations(String uid) => _db
      .collection('chats')
      .where('participants', arrayContains: uid)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) {
          final List<ChatConversation> list = snap.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    ChatConversation.fromMap(doc.id, doc.data()),
              )
              .toList();
          list.sort(
            (ChatConversation a, ChatConversation b) =>
                b.lastMessageTime.compareTo(a.lastMessageTime),
          );
          return list;
        },
      );

  Stream<List<ChatMessage>> watchMessages(String chatId) => _db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  ChatMessage.fromMap(doc.id, doc.data()),
            )
            .toList(),
      );

  Future<void> sendMessage({
    required ChatConversation conversation,
    required String senderId,
    required String text,
  }) async {
    final DocumentReference<Map<String, dynamic>> chatRef =
        _db.collection('chats').doc(conversation.id);
    final DocumentReference<Map<String, dynamic>> msgRef =
        chatRef.collection('messages').doc();

    final WriteBatch batch = _db.batch();
    batch.set(chatRef, conversation.toMap(), SetOptions(merge: true));
    batch.set(
      msgRef,
      ChatMessage(
        id: '',
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
      ).toMap(),
    );
    batch.update(chatRef, <String, dynamic>{
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
    });
    await batch.commit();
  }
}
